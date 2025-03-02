import token_registry.aleo;

program aanya_vesting_token.aleo {
    const ADMIN: address = aleo1v7nr80exf6p2709py6xf692v9f69l5cm230w23tz2p9fhx954qpq7cm7p4;

    record AccessPermission {
        owner:address,
        
    }

    struct TokenMetadata {
        token_id: field,
        name: u128,
        symbol: u128,
        decimals: u8,
        supply: u128,
        max_supply: u128,
        admin: address,
        external_authorization_required: bool,
        external_authorization_party: address
    }

    struct VestingSchedule {
        block_duration: u32,
        start_height: u32,
        number_of_interval: u32,
        total_amount: u128,
        claimed_amount: u128,
        token_id: field,  
    }
    mapping vesting_schedule:address => VestingSchedule;

    transition create_access_record (to:address) -> AccessPermission {
        assert_eq(self.caller, ADMIN);
        return AccessPermission {
            owner: to
        };
    }


    mapping registered_token:field => bool;




    async transition enroll_token (token_id:field) -> Future {
        assert_eq(self.caller,ADMIN);
        return finalize_enroll_token(token_id);
    }

    async function finalize_enroll_token (token_id:field) {
        let token:TokenMetadata = token_registry.aleo/registered_tokens.get(token_id);
        let registered: bool = registered_token.get_or_use(token_id,false);
        assert(!registered);
        registered_token.set(token_id,true);
    }

    async transition add_deposit(beneficiary:address,amount:u128, block_duration:u32, start_height:u32, number_of_interval:u32, token_id:field ) -> Future {
        assert_eq(self.caller, ADMIN);
        let deposited:Future=token_registry.aleo/transfer_public(token_id, self.address, amount);
        let beneficiary_hash_address:address = BHP256::hash_to_address(beneficiary);
        return finalize_add_deposit(amount, beneficiary_hash_address , block_duration, start_height, number_of_interval,token_id,  deposited);
    }

    async function finalize_add_deposit (amount:u128, beneficiary: address, block_duration:u32, start_height:u32, number_of_interval:u32, token_id:field, deposited:Future) {
        deposited.await();
        let token:bool = registered_token.get(token_id);
        let metadata:VestingSchedule = vesting_schedule.get_or_use(beneficiary, VestingSchedule {
            block_duration: 0u32,
            start_height: 0u32,
            number_of_interval: 0u32,
            total_amount: 0u128,
            claimed_amount: 0u128,
            token_id: token_id
        });
        let total_amount:u128 = metadata.total_amount + amount;
        assert(start_height > block.height);
        vesting_schedule.set(beneficiary, VestingSchedule {
            block_duration: block_duration,
            start_height: start_height,
            number_of_interval: number_of_interval,
            total_amount: total_amount,
            claimed_amount: metadata.claimed_amount,
            token_id: token_id
        });
    
    }


    async transition redeem_tokens(access_record: AccessPermission, amount:u128, token_id: field, external_authorization_required: bool) -> (token_registry.aleo/Token, AccessPermission,Future) {
        let (token_record,transfer):(token_registry.aleo/Token, Future)=token_registry.aleo/transfer_public_to_private(token_id, access_record.owner, amount, external_authorization_required);
        let beneficiary_hash_address:address = BHP256::hash_to_address(access_record.owner);
        let new_access_record:AccessPermission = AccessPermission {
            owner: access_record.owner
        };
        return (token_record, new_access_record, finalize_redeem_tokens(amount, token_id, beneficiary_hash_address, transfer));
    }

    async function finalize_redeem_tokens (amount:u128, token_id:field, beneficiary:address, transfer:Future) {
        transfer.await();
        let metadata:VestingSchedule = vesting_schedule.get(beneficiary);
        let claimed_amount:u128 = metadata.claimed_amount + amount;
        assert(claimed_amount <= metadata.total_amount);
        assert(block.height > metadata.start_height);
        assert((block.height - metadata.start_height)> (metadata.block_duration / metadata.number_of_interval));
        assert(amount == (metadata.total_amount * metadata.number_of_interval as u128 / metadata.block_duration as u128));
        vesting_schedule.set(beneficiary, VestingSchedule {
            block_duration: metadata.block_duration,
            start_height: metadata.start_height,
            number_of_interval: metadata.number_of_interval,
            total_amount: metadata.total_amount,
            claimed_amount: claimed_amount,
            token_id: metadata.token_id
        });
    }

}