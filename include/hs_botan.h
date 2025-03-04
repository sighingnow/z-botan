#include <HsFFI.h>
#include <botan/ffi.h>

// Utility Functions
int hs_botan_hex_encode(const uint8_t *x, HsInt x_off, HsInt x_len, char *out);
int hs_botan_hex_encode_lower(const uint8_t *x, HsInt x_off, HsInt x_len, char *out);
HsInt hs_botan_hex_decode(const char* hex_str, HsInt in_off, HsInt in_len, uint8_t* out);

// RNG
int hs_botan_rng_add_entropy(botan_rng_t rng, const uint8_t *seed, HsInt off, HsInt len);

// Block Cipher
int hs_botan_block_cipher_set_key(botan_block_cipher_t bc, const uint8_t *key, HsInt key_off, HsInt key_len);
int hs_botan_block_cipher_encrypt_blocks(botan_block_cipher_t bc
    , const uint8_t in[], HsInt off, uint8_t out[], HsInt blocks);
int hs_botan_block_cipher_decrypt_blocks(botan_block_cipher_t bc
    , const uint8_t in[], HsInt off, uint8_t out[], HsInt blocks);

// Hash
int hs_botan_hash_update(botan_hash_t hash, const uint8_t *input, HsInt off, HsInt len);

// MAC

//

// Cipher Mode
int hs_botan_cipher_set_key(botan_cipher_t cipher, const uint8_t* key, HsInt key_off, HsInt key_len);
int hs_botan_cipher_set_associated_data(botan_cipher_t cipher, const uint8_t* ad, HsInt ad_off, HsInt ad_len);
int hs_botan_cipher_start(botan_cipher_t cipher, const uint8_t* nonce, HsInt nonce_off, HsInt nonce_len);
// output buffer length should be at least equal to input length, 
// which must be larger than botan_cipher_get_update_granularity
// input_consumed == output_written
HsInt hs_botan_cipher_update(botan_cipher_t cipher_obj,
                               uint8_t* output,
                               const uint8_t* input,
                               HsInt input_off,
                               HsInt input_len);
// output buffer length should be at least equal to following call's result
// botan_cipher_output_length(cipher, input_length, &output_length)
// output_written may differ
HsInt hs_botan_cipher_finish(botan_cipher_t cipher_obj,
                           uint8_t* output,
                           HsInt output_len,
                           const uint8_t* input,
                           HsInt input_off,
                           HsInt input_len);

// Multiple Precision Integers

int hs_botan_mp_to_hex(botan_mp_t mp, char *out, HsInt off);
HsInt hs_botan_mp_to_dec(botan_mp_t mp, char *out, HsInt off);
int hs_botan_mp_set_from_hex(botan_mp_t dest, const char *str, HsInt off, HsInt len);
int hs_botan_mp_set_from_dec(botan_mp_t dest, const char *str, HsInt off, HsInt len);
int hs_botan_mp_from_bin(botan_mp_t mp, const uint8_t* vec, HsInt off, HsInt len);
int hs_botan_mp_to_bin(botan_mp_t mp, uint8_t* vec, HsInt off);

// KDF & PBKDF
int hs_botan_kdf(const char* algo
                ,uint8_t out[], HsInt out_len
                ,const uint8_t passwd[], HsInt passwd_off, HsInt passwd_len
                ,const uint8_t salt[], HsInt salt_off, HsInt salt_len
                ,const uint8_t label[], HsInt label_off, HsInt label_len);

int hs_botan_pwdhash(const char* algo
                    ,HsInt p1, HsInt p2, HsInt p3
                    ,uint8_t out[], HsInt out_len
                    ,const char* passwd, HsInt passwd_off, HsInt passwd_len
                    ,const uint8_t salt[], HsInt salt_off, HsInt salt_len);
int hs_botan_pwdhash_timed(const char* algo
                          ,uint32_t msec
                          ,uint8_t out[], HsInt out_len
                          ,const char* passwd, HsInt passwd_off, HsInt passwd_len
                          ,const uint8_t salt[], HsInt salt_off, HsInt salt_len);

HsInt hs_botan_bcrypt_generate(uint8_t *out, const char *pwd, HsInt pwd_off, HsInt pwd_len
    , botan_rng_t rng, HsInt work_factor, uint32_t flags);
int hs_botan_bcrypt_is_valid(const char* pwd, HsInt pwd_off, HsInt pwd_len
    , const char* hash, HsInt hash_off, HsInt hash_len);

// MAC

int hs_botan_mac_set_key(botan_mac_t mac, const uint8_t* key, HsInt key_off, HsInt key_len);
int hs_botan_mac_update(botan_mac_t mac, const uint8_t* buf, HsInt off, HsInt len);
int hs_botan_mac_final(botan_mac_t mac, uint8_t out[]);
int hs_botan_mac_clear(botan_mac_t mac);
int hs_botan_mac_name(botan_mac_t mac, char* name, size_t* name_len);
int hs_botan_mac_get_keyspec(botan_mac_t mac,
    size_t* out_minimum_keylength,
    size_t* out_maximum_keylength,
    size_t* out_keylength_modulo);




// Password Hashing


// Public Key Creation, Import and Export

// RSA specific functions

// DSA specific functions

// ElGamal specific functions

// Diffie-Hellman specific functions

// Public Key Encryption/Decryption

// Signature Generation & Signature Verification
int hs_botan_pk_op_sign_update(botan_pk_op_sign_t op, const uint8_t * in, HsInt off , HsInt len);

int hs_botan_pk_op_sign_finish(botan_pk_op_sign_t op, botan_rng_t rng,
                            uint8_t * sig, size_t* sig_len);


int hs_botan_pk_op_verify_update(botan_pk_op_verify_t op, const uint8_t * in, HsInt off, HsInt in_len);
int hs_botan_pk_op_verify_finish(botan_pk_op_verify_t op, const uint8_t * sig, HsInt off, HsInt sig_len);

// Key Agreement

// X.509 Certificates & X.509 Certificate Revocation Lists

// OTP

// Key wrap
