// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "../OrderRFQLib.sol";
import "../libraries/InputLib.sol";

interface IOrderRFQMixin {
    error RFQPrivateOrder();
    error RFQBadSignature();
    error RFQOrderExpired();
    error MakingAmountExceeded();
    error TakingAmountExceeded();
    error RFQSwapWithZeroAmount();
    error RFQPartialFillNotAllowed();
    error InvalidatedOrder();

    /**
     * @notice Emitted when RFQ gets filled
     * @param orderHash Hash of the order
     * @param makingAmount Amount of the maker asset that was transferred from maker to taker
     */
    event OrderFilledRFQ(
        bytes32 orderHash,
        uint256 makingAmount
    );

    /**
     * @notice Returns bitmask for double-spend invalidators based on lowest byte of order.info and filled quotes
     * @param maker Maker address
     * @param slot Slot number to return bitmask for
     * @return result Each bit represents whether corresponding was already invalidated
     */
    function invalidatorForOrderRFQ(address maker, uint256 slot) external view returns(uint256);

    /**
     * @notice Cancels order's quote
     * @param orderInfo Order info (only order id in lowest 64 bits is used)
     */
    function cancelOrderRFQ(uint256 orderInfo) external;

    /**
     * @notice Cancels multiple order's quotes
     */
    function cancelOrderRFQ(uint256 orderInfo, uint256 additionalMask) external;

    /**
     * @notice Fills order's quote, fully or partially (whichever is possible)
     * @param order Order quote to fill
     * @param r R component of signature
     * @param vs VS component of signature
     * @param input Fill configuration flags with amount packed in one slot
     * @return makingAmount Actual amount transferred from maker to taker
     * @return takingAmount Actual amount transferred from taker to maker
     * @return orderHash Hash of the filled order
     */
    function fillOrderRFQ(
        OrderRFQLib.OrderRFQ calldata order,
        bytes32 r,
        bytes32 vs,
        Input input
    ) external payable returns(uint256 makingAmount, uint256 takingAmount, bytes32 orderHash);

    /**
     * @notice Same as `fillOrderRFQ` but allows to specify funds destination instead of `msg.sender`
     * @param order Order quote to fill
     * @param r R component of signature
     * @param vs VS component of signature
     * @param input Fill configuration flags with amount packed in one slot
     * @param target Address that will receive swap funds
     * @param interaction A call data for Interactive. Taker may execute interaction after getting maker assets and before sending taker assets.
     * @return makingAmount Actual amount transferred from maker to taker
     * @return takingAmount Actual amount transferred from taker to maker
     * @return orderHash Hash of the filled order
     */
    function fillOrderRFQTo(
        OrderRFQLib.OrderRFQ calldata order,
        bytes32 r,
        bytes32 vs,
        Input input,
        address target,
        bytes calldata interaction
    ) external payable returns(uint256 makingAmount, uint256 takingAmount, bytes32 orderHash);

    /**
     * @notice Same as `fillOrderRFQTo` but calls permit first.
     * It allows to approve token spending and make a swap in one transaction.
     * Also allows to specify funds destination instead of `msg.sender`
     * @param order Order quote to fill
     * @param r R component of signature
     * @param vs VS component of signature
     * @param input Fill configuration flags with amount packed in one slot
     * @param target Address that will receive swap funds
     * @param interaction A call data for Interactive. Taker may execute interaction after getting maker assets and before sending taker assets.
     * @param permit Should contain abi-encoded calldata for `IERC20Permit.permit` call
     * @return makingAmount Actual amount transferred from maker to taker
     * @return takingAmount Actual amount transferred from taker to maker
     * @return orderHash Hash of the filled order
     * @dev See tests for examples
     */
    function fillOrderRFQToWithPermit(
        OrderRFQLib.OrderRFQ calldata order,
        bytes32 r,
        bytes32 vs,
        Input input,
        address target,
        bytes calldata interaction,
        bytes calldata permit
    ) external returns(uint256 makingAmount, uint256 takingAmount, bytes32 orderHash);

    /**
     * @notice Same as `fillOrderRFQTo` but calls permit first.
     * It allows to approve token spending and make a swap in one transaction.
     * Also allows to specify funds destination instead of `msg.sender`
     * @param order Order quote to fill
     * @param signature Signature to confirm quote ownership
     * @param input Fill configuration flags with amount packed in one slot
     * @param target Address that will receive swap funds
     * @param interaction A call data for Interactive. Taker may execute interaction after getting maker assets and before sending taker assets.
     * @param permit Should contain abi-encoded calldata for `IERC20Permit.permit` call
     * @return makingAmount Actual amount transferred from maker to taker
     * @return takingAmount Actual amount transferred from taker to maker
     * @return orderHash Hash of the filled order
     * @dev See tests for examples
     */
    function fillContractOrderRFQ(
        OrderRFQLib.OrderRFQ calldata order,
        bytes calldata signature,
        Input input,
        address target,
        bytes calldata interaction,
        bytes calldata permit
    ) external returns(uint256 makingAmount, uint256 takingAmount, bytes32 orderHash);
}
