// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/Mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;
    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaETHConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilETHConfig();
        }
    }

    struct NetworkConfig {
        address priceFeedAddress;
    }

    function getSepoliaETHConfig() public pure returns (NetworkConfig memory) {
        // https://docs.chain.link/data-feeds/price-feeds/addresses?network=ethereum&page=1
        NetworkConfig memory sepoliaCfg = NetworkConfig({
            priceFeedAddress: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaCfg;
    }

    function getOrCreateAnvilETHConfig() public returns (NetworkConfig memory) {
        // ensure there is no active network config
        if (activeNetworkConfig.priceFeedAddress != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilCfg = NetworkConfig({
            priceFeedAddress: address(mockV3Aggregator)
        });
        return anvilCfg;
    }
}
