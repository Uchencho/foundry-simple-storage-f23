KEY_NAME = simpleStorageKey
DEVELOPMENT_KEY_NAME = devKey
SENDER_ADDRESS = 0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266
DEVELOPMENT_KEY_ADDRESS=0x2fef53a901d213c41a82e9f7dfba867d6c06d253
ADDRESS_OF_CONTRACT = 0x5FbDB2315678afecb367f032d93F642f64180aa3
FUNCTION_NAME = "store(uint256)"
RETRIEVE_FUNCTION_NAME = "retrieve()"
FUNCTION_ARGUMENTS = "123"
RPC_URL=http://127.0.0.1:8545
HEX_VALUE = 0x000000000000000000000000000000000000000000000000000000000000007b
SEPOLIA_ETH_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/oJssw8ykgmAldENDw4nKdgm3Irn0PZG_

# To store the private key in a key store, we need to use the following command:
storeKey:
	cast wallet import $(KEY_NAME) --interactive

deployContract:
	forge script script/DeploySimpleStorage.s.sol --rpc-url $(RPC_URL) --account $(KEY_NAME) --sender $(SENDER_ADDRESS) --broadcast

deployContractOnSepolia:
	forge script script/DeploySimpleStorage.s.sol --rpc-url $(SEPOLIA_ETH_RPC_URL) \
	--account $(DEVELOPMENT_KEY_NAME) --sender $(DEVELOPMENT_KEY_ADDRESS)

invokeStoreFunction:
	cast send $(ADDRESS_OF_CONTRACT) $(FUNCTION_NAME) $(FUNCTION_ARGUMENTS) --rpc-url $(RPC_URL) \
	 --account $(KEY_NAME)

invokeRetrieveFunction:
	cast call $(ADDRESS_OF_CONTRACT) $(RETRIEVE_FUNCTION_NAME) --rpc-url $(RPC_URL)

convertHexToDecimal:
	cast --to-base $(HEX_VALUE) dec

# Without the fork url, you won't be able to interact with the price feed contract because it is on chain
# And the test runs on anvil deployed locally. With the fork, it will simulate what is on the sepolia chain
# Still running locally though
testPriceFeedIsAccurate:
	forge test --match-test testPriceFeedIsAccurate -vvv --fork-url $(SEPOLIA_ETH_RPC_URL)

# We no longer need the fork url because we are mocking the price feed aggregator and deploying it on anvil
testPriceFeedIsAccurateOnAnvil:
	forge test --match-test testPriceFeedIsAccurate -vvv

testCoverage:
	forge coverage --fork-url $(SEPOLIA_ETH_RPC_URL)