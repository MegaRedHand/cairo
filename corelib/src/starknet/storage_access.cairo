use traits::{Into, TryInto};
use option::OptionTrait;
use starknet::{
    SyscallResult, syscalls::{storage_read_syscall, storage_write_syscall},
    contract_address::{ContractAddress, Felt252TryIntoContractAddress, ContractAddressIntoFelt252},
    class_hash::{ClassHash, Felt252TryIntoClassHash, ClassHashIntoFelt252}
};
use serde::Serde;

#[derive(Copy, Drop)]
extern type StorageAddress;

#[derive(Copy, Drop)]
extern type StorageBaseAddress;

// Storage.
extern fn storage_base_address_const<const address: felt252>() -> StorageBaseAddress nopanic;
extern fn storage_base_address_from_felt252(
    addr: felt252
) -> StorageBaseAddress implicits(RangeCheck) nopanic;

extern fn storage_address_to_felt252(address: StorageAddress) -> felt252 nopanic;
extern fn storage_address_from_base_and_offset(
    base: StorageBaseAddress, offset: u8
) -> StorageAddress nopanic;

extern fn storage_address_from_base(base: StorageBaseAddress) -> StorageAddress nopanic;

extern fn storage_address_try_from_felt252(
    address: felt252
) -> Option<StorageAddress> implicits(RangeCheck) nopanic;

impl Felt252TryIntoStorageAddress of TryInto<felt252, StorageAddress> {
    fn try_into(self: felt252) -> Option<StorageAddress> {
        storage_address_try_from_felt252(self)
    }
}
impl StorageAddressIntoFelt252 of Into<StorageAddress, felt252> {
    fn into(self: StorageAddress) -> felt252 {
        storage_address_to_felt252(self)
    }
}

impl StorageAddressSerde of serde::Serde<StorageAddress> {
    fn serialize(self: @StorageAddress, ref output: Array<felt252>) {
        storage_address_to_felt252(*self).serialize(ref output);
    }
    fn deserialize(ref serialized: Span<felt252>) -> Option<StorageAddress> {
        Option::Some(
            storage_address_try_from_felt252(serde::Serde::<felt252>::deserialize(ref serialized)?)?
        )
    }
}

trait StorageAccess<T> {
    fn read(address_domain: u32, base: StorageBaseAddress, offset: u8) -> SyscallResult<T>;
    fn write(
        address_domain: u32, base: StorageBaseAddress, offset: u8, value: T
    ) -> SyscallResult<()>;
    // TODO(orizi): Make this into a const generics.
    fn size() -> u8;
}

impl StorageAccessFelt252 of StorageAccess<felt252> {
    #[inline(always)]
    fn read(address_domain: u32, base: StorageBaseAddress, offset: u8) -> SyscallResult<felt252> {
        storage_read_syscall(address_domain, storage_address_from_base_and_offset(base, offset))
    }
    #[inline(always)]
    fn write(
        address_domain: u32, base: StorageBaseAddress, offset: u8, value: felt252
    ) -> SyscallResult<()> {
        storage_write_syscall(
            address_domain, storage_address_from_base_and_offset(base, offset), value
        )
    }
    #[inline(always)]
    fn size() -> u8 {
        1_u8
    }
}

impl StorageAccessBool of StorageAccess<bool> {
    #[inline(always)]
    fn read(address_domain: u32, base: StorageBaseAddress, offset: u8) -> SyscallResult<bool> {
        Result::Ok(StorageAccess::<felt252>::read(address_domain, base, offset)? != 0)
    }
    #[inline(always)]
    fn write(
        address_domain: u32, base: StorageBaseAddress, offset: u8, value: bool
    ) -> SyscallResult<()> {
        StorageAccess::<felt252>::write(address_domain, base, offset, if value {
            1
        } else {
            0
        })
    }
    #[inline(always)]
    fn size() -> u8 {
        1_u8
    }
}

impl StorageAccessU8 of StorageAccess<u8> {
    #[inline(always)]
    fn read(address_domain: u32, base: StorageBaseAddress, offset: u8) -> SyscallResult<u8> {
        Result::Ok(
            StorageAccess::<felt252>::read(address_domain, base, offset)?
                .try_into()
                .expect('StorageAccessU8 - non u8')
        )
    }
    #[inline(always)]
    fn write(
        address_domain: u32, base: StorageBaseAddress, offset: u8, value: u8
    ) -> SyscallResult<()> {
        StorageAccess::<felt252>::write(address_domain, base, offset, value.into())
    }
    #[inline(always)]
    fn size() -> u8 {
        1_u8
    }
}

impl StorageAccessU16 of StorageAccess<u16> {
    #[inline(always)]
    fn read(address_domain: u32, base: StorageBaseAddress, offset: u8) -> SyscallResult<u16> {
        Result::Ok(
            StorageAccess::<felt252>::read(address_domain, base, offset)?
                .try_into()
                .expect('StorageAccessU16 - non u16')
        )
    }
    #[inline(always)]
    fn write(
        address_domain: u32, base: StorageBaseAddress, offset: u8, value: u16
    ) -> SyscallResult<()> {
        StorageAccess::<felt252>::write(address_domain, base, offset, value.into())
    }
    #[inline(always)]
    fn size() -> u8 {
        1_u8
    }
}

impl StorageAccessU32 of StorageAccess<u32> {
    #[inline(always)]
    fn read(address_domain: u32, base: StorageBaseAddress, offset: u8) -> SyscallResult<u32> {
        Result::Ok(
            StorageAccess::<felt252>::read(address_domain, base, offset)?
                .try_into()
                .expect('StorageAccessU32 - non u32')
        )
    }
    #[inline(always)]
    fn write(
        address_domain: u32, base: StorageBaseAddress, offset: u8, value: u32
    ) -> SyscallResult<()> {
        StorageAccess::<felt252>::write(address_domain, base, offset, value.into())
    }
    #[inline(always)]
    fn size() -> u8 {
        1_u8
    }
}

impl StorageAccessU64 of StorageAccess<u64> {
    #[inline(always)]
    fn read(address_domain: u32, base: StorageBaseAddress, offset: u8) -> SyscallResult<u64> {
        Result::Ok(
            StorageAccess::<felt252>::read(address_domain, base, offset)?
                .try_into()
                .expect('StorageAccessU64 - non u64')
        )
    }
    #[inline(always)]
    fn write(
        address_domain: u32, base: StorageBaseAddress, offset: u8, value: u64
    ) -> SyscallResult<()> {
        StorageAccess::<felt252>::write(address_domain, base, offset, value.into())
    }
    #[inline(always)]
    fn size() -> u8 {
        1_u8
    }
}

impl StorageAccessU128 of StorageAccess<u128> {
    #[inline(always)]
    fn read(address_domain: u32, base: StorageBaseAddress, offset: u8) -> SyscallResult<u128> {
        Result::Ok(
            StorageAccess::<felt252>::read(address_domain, base, offset)?
                .try_into()
                .expect('StorageAccessU128 - non u128')
        )
    }
    #[inline(always)]
    fn write(
        address_domain: u32, base: StorageBaseAddress, offset: u8, value: u128
    ) -> SyscallResult<()> {
        StorageAccess::<felt252>::write(address_domain, base, offset, value.into())
    }
    #[inline(always)]
    fn size() -> u8 {
        1_u8
    }
}

impl StorageAccessStorageAddress of StorageAccess<StorageAddress> {
    #[inline(always)]
    fn read(
        address_domain: u32, base: StorageBaseAddress, offset: u8
    ) -> SyscallResult<StorageAddress> {
        Result::Ok(
            StorageAccess::<felt252>::read(address_domain, base, offset)?
                .try_into()
                .expect('Non StorageAddress')
        )
    }
    #[inline(always)]
    fn write(
        address_domain: u32, base: StorageBaseAddress, offset: u8, value: StorageAddress
    ) -> SyscallResult<()> {
        StorageAccess::<felt252>::write(address_domain, base, offset, value.into())
    }
    #[inline(always)]
    fn size() -> u8 {
        1_u8
    }
}

impl StorageAccessContractAddress of StorageAccess<ContractAddress> {
    #[inline(always)]
    fn read(
        address_domain: u32, base: StorageBaseAddress, offset: u8
    ) -> SyscallResult<ContractAddress> {
        Result::Ok(
            StorageAccess::<felt252>::read(address_domain, base, offset)?
                .try_into()
                .expect('Non ContractAddress')
        )
    }
    #[inline(always)]
    fn write(
        address_domain: u32, base: StorageBaseAddress, offset: u8, value: ContractAddress
    ) -> SyscallResult<()> {
        StorageAccess::<felt252>::write(address_domain, base, offset, value.into())
    }
    #[inline(always)]
    fn size() -> u8 {
        1_u8
    }
}

impl StorageAccessClassHash of StorageAccess<ClassHash> {
    #[inline(always)]
    fn read(address_domain: u32, base: StorageBaseAddress, offset: u8) -> SyscallResult<ClassHash> {
        Result::Ok(
            StorageAccess::<felt252>::read(address_domain, base, offset)?
                .try_into()
                .expect('Non ClassHash')
        )
    }
    #[inline(always)]
    fn write(
        address_domain: u32, base: StorageBaseAddress, offset: u8, value: ClassHash
    ) -> SyscallResult<()> {
        StorageAccess::<felt252>::write(address_domain, base, offset, value.into())
    }
    #[inline(always)]
    fn size() -> u8 {
        1_u8
    }
}
