// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {IConnext} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ConnextLPxReceiver is IXReceiver {

    IConnext public immutable connext;

    constructor(IConnext _connext) {    
        connext = _connext;  
    }

    /** @notice The receiver function as required by the IXReceiver interface.    
      * @dev The Connext bridge contract will call this function.    
    */  
    function xReceive(    
        bytes32 _transferId,    
        uint256 _amount,    
        address _asset,    
        address _originSender,    
        uint32 _origin,    
        bytes memory _callData  
    ) external returns (bytes memory) {
        (bytes32 _key, uint256 _minToMint, uint256 _deadline, address _recipient) = abi.decode(_callData,(bytes32, uint256, uint256));
        uint256 LPtokenAmount = connext.addSwapLiquidity(
            _key,
            [_amount, 0], // TODO figure out how to structure this and which asset we have
            _minToMint,
            _deadline
        );
        address LPtokenAddress = connext.getSwapLPToken(_key);
        IERC20(LPtokenAddress).transfer(_recipient, LPtokenAmount);
        IERC20(_asset).transfer(_recipient, _amount);
    }
}
