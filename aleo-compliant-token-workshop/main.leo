import token_registry.aleo;

// The 'compliant_token_aanya' program.
program compliant_token_aanya.aleo {


  const COMPLAINT_TOKEN_ID: field = 71619063553950105623552field; // Unique token identifier

  // registered projectS are stored in a mapping with the project ID as the key
  mapping registered_project: field => address;
  mapping project_time: field => u32;
  mapping project_balance: field => u128;
  mapping project_goal: field => u128;


  async transition register_project(project_id: field, expiry_time: u32, money_goal: u128) -> Future{
    return (finalize_register_project(self.caller, project_id, expiry_time)); // Await the finalization process
  }

  async function finalize_register_project(project_owner: address, project_id: field, expiry_time: u32) {
    registered_project.set(project_id, project_owner);
    project_time.set(project_id, expiry_time);
    project_goal.set(project_id, 0u128);
  }

  /**
   * Transfers tokens privately 
   */
  async transition fund_private(
    input_token: token_registry.aleo/Token, // The input token record to be spent
    amount: u128, // Amount to transfer
    project_id: field, // Recipient project ID
  ) -> (token_registry.aleo/Token, Future) {
    
    let transfer_output: (token_registry.aleo/Token, Future) = token_registry.aleo/transfer_private_to_public(
      compliant_token_sandip.aleo,
      amount,
      input_token
    );

    return (
        transfer_output.0, // Return the unauthorized token
      finalize_fund_private(transfer_output.1, amount, project_id) // Await the finalization process
    );
  }

  /**
   * Finalizes the transfer
   */
  async function finalize_fund_private(
    f0: Future, // Future from transfer_private
    amount: u128, // Amount to transfer
    project_id: field // Recipient project ID
  ) {
    f0.await();
    let current_balance: u128 = project_balance.get_or_use(project_id, 0u128);
    project_balance.set(project_id, current_balance + amount);    
    assert(block.height < project_time.get(project_id));
  }


  async transition get_money(project_id: field, amount: u128) -> Future {
    let transfer_output: Future = token_registry.aleo/transfer_public(
      COMPLAINT_TOKEN_ID,
      self.caller,
      amount
    );
    return finalize_get_money(self.caller, project_id, amount, transfer_output);
  }

  async function finalize_get_money(project_owner: address, project_id: field, amount: u128, f0: Future) {
    f0.await();
    let current_balance: u128 = project_balance.get_or_use(project_id, 0u128);
    project_balance.set(project_id, current_balance - amount);
    assert(block.height > project_time.get(project_id));
  }

}