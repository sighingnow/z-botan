{-|
Module      : Z.Crypto.PwdHash
Description : Password Hashing
Copyright   : Dong Han, 2021
License     : BSD
Maintainer  : winterland1989@gmail.com
Stability   : experimental
Portability : non-portable

Storing passwords for user authentication purposes in plaintext is the simplest but least secure method; when an attacker compromises the database in which the passwords are stored, they immediately gain access to all of them. Often passwords are reused among multiple services or machines, meaning once a password to a single service is known an attacker has a substantial head start on attacking other machines.

The general approach is to store, instead of the password, the output of a one way function of the password. Upon receiving an authentication request, the authenticating party can recompute the one way function and compare the value just computed with the one that was stored. If they match, then the authentication request succeeds. But when an attacker gains access to the database, they only have the output of the one way function, not the original password.

Common hash functions such as SHA-256 are one way, but used alone they have problems for this purpose. What an attacker can do, upon gaining access to such a stored password database, is hash common dictionary words and other possible passwords, storing them in a list. Then he can search through his list; if a stored hash and an entry in his list match, then he has found the password. Even worse, this can happen offline: an attacker can begin hashing common passwords days, months, or years before ever gaining access to the database. In addition, if two users choose the same password, the one way function output will be the same for both of them, which will be visible upon inspection of the database.

There are two solutions to these problems: salting and iteration. Salting refers to including, along with the password, a randomly chosen value which perturbs the one way function. Salting can reduce the effectiveness of offline dictionary generation, because for each potential password, an attacker would have to compute the one way function output for all possible salts. It also prevents the same password from producing the same output, as long as the salts do not collide. Choosing n-bit salts randomly, salt collisions become likely only after about 2:sup:(n/2) salts have been generated. Choosing a large salt (say 80 to 128 bits) ensures this is very unlikely. Note that in password hashing salt collisions are unfortunate, but not fatal - it simply allows the attacker to attack those two passwords in parallel easier than they would otherwise be able to.

The other approach, iteration, refers to the general technique of forcing multiple one way function evaluations when computing the output, to slow down the operation. For instance if hashing a single password requires running SHA-256 100,000 times instead of just once, that will slow down user authentication by a factor of 100,000, but user authentication happens quite rarely, and usually there are more expensive operations that need to occur anyway (network and database I/O, etc). On the other hand, an attacker who is attempting to break a database full of stolen password hashes will be seriously inconvenienced by a factor of 100,000 slowdown; they will be able to only test at a rate of .0001% of what they would without iterations (or, equivalently, will require 100,000 times as many zombie botnet hosts).

Memory usage while checking a password is also a consideration; if the computation requires using a certain minimum amount of memory, then an attacker can become memory-bound, which may in particular make customized cracking hardware more expensive. Some password hashing designs, such as scrypt, explicitly attempt to provide this. The bcrypt approach requires over 4 KiB of RAM (for the Blowfish key schedule) and may also make some hardware attacks more expensive.
-}

module Z.Crypto.PwdHash where

import Z.Botan.Exception
import Z.Botan.FFI
import Z.Crypto.RNG (RNG, withRNG)
import Z.Foreign
import qualified Z.Data.Vector.Base as V

-- | Create a password hash using Bcrypt.
--
-- Bcrypt is a password hashing scheme originally designed for use in OpenBSD, but numerous other implementations exist. It has the advantage that it requires a small amount (4K) of fast RAM to compute, which can make hardware password cracking somewhat more expensive.
--
-- Bcrypt provides outputs that look like this:
--
-- >>> "$2a$12$7KIYdyv8Bp32WAvc.7YvI.wvRlyVn0HP/EhPmmOyMQA4YKxINO0p2"
--
-- Higher work factors increase the amount of time the algorithm runs, increasing the cost of cracking attempts. The increase is exponential, so a work factor of 12 takes roughly twice as long as work factor 11. The default work factor was set to 10 up until the 2.8.0 release.
--
-- It is recommended to set the work factor as high as your system can tolerate (from a performance and latency perspective) since higher work factors greatly improve the security against GPU-based attacks. For example, for protecting high value administrator passwords, consider using work factor 15 or 16; at these work factors each bcrypt computation takes several seconds. Since admin logins will be relatively uncommon, it might be acceptable for each login attempt to take some time. As of 2018, a good password cracking rig (with 8 NVIDIA 1080 cards) can attempt about 1 billion bcrypt computations per month for work factor 13. For work factor 12, it can do twice as many. For work factor 15, it can do only one quarter as many attempts.
--
-- The bcrypt work factor must be at least 4 (though at this work factor bcrypt is not very secure). The bcrypt format allows up to 31, but Botan currently rejects all work factors greater than 18 since even that work factor requires roughly 15 seconds of computation on a fast machine.
--
genBcrypt :: V.Bytes    -- ^ password.
          -> RNG
          -> Int        -- ^ work factors (4 <= n <= 18).
          -> IO V.Bytes
genBcrypt pwd rng n = do
    withPrimVectorUnsafe pwd $ \ pwd_p pwd_off pwd_len ->
        withRNG rng $ \ rng_p -> do
            (pa, r) <- allocPrimArrayUnsafe 64 $ \ out -> do
                throwBotanIfMinus $
                    hs_botan_bcrypt_generate out
                        pwd_p pwd_off pwd_len rng_p n 0
            let !r' = r - 1
            mpa <- unsafeThawPrimArray pa
            shrinkMutablePrimArray mpa r'
            pa' <- unsafeFreezePrimArray mpa
            return (V.PrimVector pa' 0 r')

-- | Takes a password and a bcrypt output and returns true if the password is the same as the one that was used to generate the bcrypt hash.
--
validBcrypt :: V.Bytes -- ^ password.
            -> V.Bytes -- ^ hash generated by 'genBcrypt'.
            -> IO Bool
validBcrypt pwd hash = do
    withPrimVectorUnsafe pwd $ \ pwd_p pwd_off pwd_l ->
        withPrimVectorUnsafe hash $ \ hash_p hash_off hash_l -> do
            ret <- hs_botan_bcrypt_is_valid  pwd_p pwd_off pwd_l hash_p hash_off hash_l
            return $! ret == BOTAN_FFI_SUCCESS
