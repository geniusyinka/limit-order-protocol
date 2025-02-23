// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import "./IOrderMixin.sol";

/**
 * @title Interface for interactor which acts after `taker -> maker` transfers.
 * @notice The order filling steps are `preInteraction` =>` Transfer "maker -> taker"` => **`Interaction`** => `Transfer "taker -> maker"` => `postInteraction`
 */
interface ITakerInteraction {
    /**
     * @dev This callback allows to interactively hanlde maker aseets to produce takers assets, doesn't supports ETH as taker assets
     * @notice Callback method that gets called after all funds transfers
     * @param order Order being processed
     * @param orderHash Hash of the order being processed
     * @param taker Taker address
     * @param makingAmount Actual making amount
     * @param takingAmount Actual taking amount
     * @param remainingMakingAmount Order remaining making amount
     * @param extraData Extra data
     */
    function takerInteraction(
        IOrderMixin.Order calldata order,
        bytes32 orderHash,
        address taker,
        uint256 makingAmount,
        uint256 takingAmount,
        uint256 remainingMakingAmount,
        bytes calldata extraData
    ) external returns(uint256 offeredTakingAmount);
}
