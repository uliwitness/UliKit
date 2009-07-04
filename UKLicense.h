/*
 *  UKLicense.h
 *  ScreencastBuddy
 *
 *  Created by Uli Kusterer on 15.08.08.
 *  Copyright 2008 The Void Software. All rights reserved.
 *
 */

/*
	This is the client code that goes into an application to verify the license
	key for an application. This goes together with the UKLicenseMaker application,
	which you'd use to create the private/public key pair used for encrypting
	the license, as well as the actual licenses.
	
	The license is essentially a struct containing information, i.e. the name of
	the user that registered the app, how many seats a multi-user license is
	valid for, when an expiring license will expire, etc. This struct gets
	encrypted using asymmetric RSA encryption. The app only contains the public
	key needed to read the information in the license, but only the private key
	can be used to generate them.
	
	I got the idea from Allan Odgaard's article at:
	http://sigpipe.macromates.com/2004/09/05/using-openssl-for-license-keys/
	
	This implementation does a few more things:
	
	1.	Everything is done using macros, which means the code effectively gets
		'forcibly inlined' and thus duplicated throughout the app. So,
		everywhere you look at the license, a binary patch would have to change
		the code.
	
	2.	Struct and field names are obfuscated a bit to look like common
		Quickdraw data structures at first glance, in case someone disassembles
		the app.
	
	3.	There are flags for indicating variants or features of the license.
	
	4.	There's a function that turns a (binary) license key into text and back,
		which can be used to turn the license into something that'll survive
		being e-mailed.
*/

// -----------------------------------------------------------------------------
//	Headers:
// -----------------------------------------------------------------------------

#include <stdint.h>
#include "UKLicenseKey.h"
#include <openssl/sha.h>
#include <openssl/rsa.h>
#include <openssl/bio.h>
#include <openssl/pem.h>
#include <string.h>
#include <math.h>
#include <ctype.h>


// -----------------------------------------------------------------------------
//	Constants:
// -----------------------------------------------------------------------------

enum	// Possible licenseFlags values:
{
	UKLicenseFlagFloating		= (1 << 0),
	UKLicenseFlagNoUpgrades		= (1 << 1),
	UKLicenseFlagPromotional	= (1 << 2),
	UKLicenseFlagIsUpgrade		= (1 << 3),
	UKLicenseFlagReserved5		= (1 << 4),
	UKLicenseFlagReserved6		= (1 << 5),
	UKLicenseFlagReserved7		= (1 << 6),
	UKLicenseFlagReserved8		= (1 << 7),
	UKLicenseFlagReserved9		= (1 << 8),
	UKLicenseFlagReserved10		= (1 << 9),
	UKLicenseFlagReserved11		= (1 << 10),
	UKLicenseFlagReserved12		= (1 << 11),
	UKLicenseFlagReserved13		= (1 << 12),
	UKLicenseFlagReserved14		= (1 << 13),
	UKLicenseFlagReserved15		= (1 << 14),
	UKLicenseFlagValid			= (1 << 15)
};


// -----------------------------------------------------------------------------
//	Data Structures:
// -----------------------------------------------------------------------------

// Some obfuscation:
#ifndef DEBUG
#define		UKLicenseInfo			_QDGlobals
#define		ukli_licenseeName		grafPort
#define		ukli_licenseeCompany	dkGray
#define		ukli_licenseSeats		ltGray
#define		ukli_licenseVersion		gray
#define		ukli_licenseExpiration	black
#define		ukli_licenseFlags		white
#define		ukli_licenseSeed		thePort
#endif

// 128 bytes maximum size (our code can't encrypt more!):
#pragma pack(push,1)
struct UKLicenseInfo
{
	uint8_t			ukli_licenseeName[40];		// Name of user. (No zero byte, may have spaces at end)
	uint8_t			ukli_licenseeCompany[40];	// Company user works for. (May be empty. No zero byte, may have spaces at end)
	uint16_t		ukli_licenseSeats;			// Number of seats for multi-user license.
	uint8_t			ukli_licenseVersion;		// With every paid update, this gets bumped to prevent people with older licenses from using the new app.
	double			ukli_licenseExpiration;		// For time-limited demos or subscriptions, this is an NSTimeInterval indicating when the license runs out.
	uint16_t		ukli_licenseFlags;			// Bit flags, see above.
	int64_t			ukli_licenseSeed;			// Unique number identifying this license.
};
#pragma pack(pop)


// -----------------------------------------------------------------------------
//	Functions:
//		These are a bit ugly. They're macros to force them to be inlined, so
//		that hackers can't just stub out one function.
// -----------------------------------------------------------------------------

//int	UKReadableLengthForBinaryBytesOfLength( int count );

#define UKReadableLengthForBinaryBytesOfLength( count ) (((int)count) * 2)


//void	UKReadableDataForBinaryBytesOfLength( const uint8_t* inBuf, int count, uint8_t* outBuf ) \

#define	UKReadableDataForBinaryBytesOfLength( inBuf, count, outBuf ) \
do \
{ \
	uint8_t*		urdfbbol_outBuf = (outBuf); \
	const uint8_t*	urdfbbol_inBuf = (inBuf); \
	int				urdfbbol_count = (count); \
	int				urdfbbol_x = 0; \
	char*			urdfbbol_allowedChars = "0123456789ABCDEF"; \
	\
	for( urdfbbol_x = 0; urdfbbol_x < urdfbbol_count; urdfbbol_x++ ) \
	{ \
		uint8_t	urdfbbol_inByte = *urdfbbol_inBuf; \
		urdfbbol_inBuf++; \
		\
		int		urdfbbol_currHi = (urdfbbol_inByte & 0xF0) >> 4, \
				urdfbbol_currLo = urdfbbol_inByte & 0x0F; \
		*urdfbbol_outBuf = urdfbbol_allowedChars[urdfbbol_currHi]; \
		urdfbbol_outBuf++; \
		*urdfbbol_outBuf = urdfbbol_allowedChars[urdfbbol_currLo]; \
		urdfbbol_outBuf++; \
	} \
} \
while( 0 )


//int	UKBinaryLengthForReadableBytesOfLength( int count );

#define UKBinaryLengthForReadableBytesOfLength( count ) ((int)ceilf( ((float)count) / 2.0 ))


//void	UKBinaryDataForReadableBytesOfLength( const uint8_t* inBuf, int count, uint8_t* outBuf );

#define UKBinaryDataForReadableBytesOfLength( inBuf, count, outBuf ) \
{ \
	const uint8_t*	ubdfrbol_inBuf = (inBuf); \
	int				ubdfrbol_count = (count); \
	uint8_t*		ubdfrbol_outBuf = (outBuf); \
	int				ubdfrbol_x = 0; \
	char*			ubdfrbol_allowedChars = "0123456789ABCDEF"; \
	int				ubdfrbol_numAllowedChars = strlen(ubdfrbol_allowedChars); \
	\
	for( ubdfrbol_x = 0; ubdfrbol_x < ubdfrbol_count; ubdfrbol_x++ ) \
	{ \
		uint8_t	ubdfrbol_inByte = toupper(*ubdfrbol_inBuf); \
		ubdfrbol_inBuf++; \
		\
		int ubdfrbol_y = 0, ubdfrbol_currVal = 0; \
		for( ubdfrbol_y = 0; ubdfrbol_y < ubdfrbol_numAllowedChars; ubdfrbol_y++ ) \
		{ \
			if( ubdfrbol_allowedChars[ubdfrbol_y] == ubdfrbol_inByte ) \
			{ \
				ubdfrbol_currVal = ubdfrbol_y; \
				ubdfrbol_y = ubdfrbol_numAllowedChars; \
			} \
		} \
		\
		if( (ubdfrbol_x & 1) == 1 ) \
		{ \
			*ubdfrbol_outBuf |= ubdfrbol_currVal; \
			ubdfrbol_outBuf++; \
		} \
		else \
			*ubdfrbol_outBuf |= ubdfrbol_currVal << 4; \
	} \
} \
while( 0 )


// void	UKInitLicenseInfo( struct UKLicenseInfo *outInfo );

#define	UKInitLicenseInfo( outInfo ) \
do \
{ \
	struct UKLicenseInfo* ylicense_outInfo = outInfo; \
	memset( ylicense_outInfo, 0, sizeof(struct UKLicenseInfo) ); \
	memset( ylicense_outInfo->ukli_licenseeName, ' ', sizeof(ylicense_outInfo->ukli_licenseeName) ); \
	memset( ylicense_outInfo->ukli_licenseeCompany, ' ', sizeof(ylicense_outInfo->ukli_licenseeCompany) ); \
} \
while( 0 )


// void	UKGetLicenseData( const uint8_t* data, int data_size, struct UKLicenseInfo *outInfo );

#define UKGetLicenseData( data, data_size, outInfo ) \
do \
{ \
	const uint8_t*			zlicense_data = (data); \
	int						zlicense_data_size = (data_size); \
	struct UKLicenseInfo *	zlicense_outInfo = (outInfo); \
	unsigned char*			zlicense_dst = NULL; \
	BIO*					zlicense_bio = NULL; \
	int						zlicense_x = 0; \
	\
	UKInitLicenseInfo( zlicense_outInfo ); \
	\
	UKLicensePublicKey(zlicense_keybuf); \
	for( zlicense_x = 0; zlicense_x < PUB_KEY_LEN; zlicense_x++ ) \
		zlicense_keybuf[zlicense_x] ^= PUB_KEY_MASK; \
	\
	if( zlicense_bio = BIO_new_mem_buf( zlicense_keybuf, PUB_KEY_LEN ) ) \
	{ \
		RSA* zlicense_rsa_key = 0; \
		if( PEM_read_bio_RSA_PUBKEY( zlicense_bio, &zlicense_rsa_key, NULL, NULL ) ) \
		{ \
			zlicense_dst = (unsigned char*) malloc( RSA_size( zlicense_rsa_key ) ); \
			int	zlicense_decryptedDataLen = RSA_public_decrypt( zlicense_data_size, zlicense_data, \
								zlicense_dst, zlicense_rsa_key, RSA_PKCS1_PADDING ); \
			if( zlicense_decryptedDataLen <= sizeof(struct UKLicenseInfo) ) \
				memmove( zlicense_outInfo, zlicense_dst, zlicense_decryptedDataLen ); \
			free( zlicense_dst ); \
			RSA_free( zlicense_rsa_key ); \
		} \
		BIO_free( zlicense_bio ); \
	} \
} \
while( 0 )


