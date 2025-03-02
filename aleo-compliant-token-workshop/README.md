### Overview
This Leo smart contract implements a platform where users can register their projects and receive private funding from others using compliant tokens. Users can register projects with a specific fundraising goal and expiration time. Once the project has ended, project owners can claim their funds publicly. All transfers are done privately until the project is funded.

### Running the Program

Follow these steps to run the program :

1. **Compile the Program**:
   Use the following command to compile the program:
   ```bash
   leo build
   ```

2. **Run Functions**:
   You can execute specific functions with the Leo CLI using the command:
   ```bash
   leo run <function_name> <input_1> <input_2> ...
   ```
   For more examples, see the `./run.sh` script.

### Configuring Accounts
The `.env` file contains a private key that is used to sign transactions and verify ownership of records. When executing the program on behalf of different accounts (i.e., project owners or donors), ensure that the `PRIVATE_KEY` field in the `.env` file is updated with the correct key for each respective account.

To create or switch between different accounts, follow these steps:

1. **Generate New Accounts**:
   You can generate new accounts using the [Aleo SDK](https://provable.tools). This tool allows you to create new Aleo accounts with unique public and private keys.

2. **Update Private Key**:
   Modify the `.env` file with the appropriate `PRIVATE_KEY` value corresponding to the account you're running the program for.

### Providing Inputs via Command Line
To run a specific function with input arguments, use the following command structure:
```bash
leo run <function_name> <input_1> <input_2> ...
```

For example, to register a new project, you would run:
```bash
leo run register_project <project_id> <expiry_time> <money_goal>
```