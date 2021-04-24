// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/* @title Staking Pool Contract
 * Open Zeppelin Pausable  */

contract StakingpoolV2 is Initializable, ContextUpgradeable, ReentrancyGuardUpgradeable, PausableUpgradeable, OwnableUpgradeable {
    using SafeMathUpgradeable for uint256;

    uint256 StakePeriod;

    IERC20Upgradeable public MCHToken;

    IERC20Upgradeable public MCFToken;

    /** @dev track total current stake yields of a user */
    mapping(address => uint256) public currentstakeyields;

    /* @dev track Stakedbalances of user*/
    mapping(address => uint256) public stakedBalances;

    /** @dev track StakedShares of user */
    mapping(address => uint256) public stakedShares;

    /** @dev track total staked amount of tokens of all users */
    uint256 public totalStakedMcH;

    /** @dev track MCH value */
    uint256 public MCH;

    /** @dev track MCF value */
    uint256 public MCF;

    /** @dev track total staked value of all users */
    uint256 public totalStakedamount;

    /** @dev track Daily Rate of Investment */
    mapping(address => uint256) public DROI;

    /** @dev track Monthly Rate of Investment */
    mapping(address => uint256) public MROI;

    /** @dev track Annual Rate of Investment */
    mapping(address => uint256) public ROI;

    /** @dev track claimable tokens */
    mapping(address => uint256) public claimable;

    /** @dev track vested tokens */
    mapping(address => uint256) public vested;

    /** @dev track users
     * users must be tracked in this array because mapping is not iterable */
    address[] public users;

    /** @dev track index by address added to blacklisted */
    mapping(address => bool) private _blackListed;

    /** @dev track index by address added to users */
    mapping(address => uint256) private userIndex;

    /** @dev track stake time of users */
    mapping(address => uint256) internal creationTime;

    /** @dev track whether users has completed stake period */
    mapping(address => bool) isFinalized;

    /** @dev track staked status of users */
    mapping(address => bool) Staked;

    /** @dev track staking status of users */
    mapping(address => bool) isStaking;

    /** @dev trigger notification of staked amount
     * @param sender       msg.sender for the transaction
     * @param amount       msg.value for the transaction
     */
    event NotifyStaked(address sender, uint256 amount);

    /** @dev trigger notification of unstaked amount
     * @param sender       msg.sender for the transaction
     * @param amount       msg.value for the transaction
     */
    event NotifyUnStaked(address sender, uint256 amount);

    // @dev trigger notification of claimed amount
    event Notifyclaimed(address sender, uint256 Balance);

    /**
     * @dev Throws if called before stakingperiod
     */
    modifier onlyAfter() {
        require(block.timestamp >= creationTime[msg.sender].add(StakePeriod), "StakePeriod not completed");
        _;
    }

    // @dev contract Initializable

    function Initialize(address _MCHToken, address _MCFToken) public initializer {
        MCHToken = IERC20Upgradeable(_MCHToken);
        MCFToken = IERC20Upgradeable(_MCFToken);
        StakePeriod = 11 days;
    }

    /** @dev test if user is in current user list
     * @param user address of user to test if in list
     * @return true if user is on record, otherwise false
     */
    function isUser(address user) internal view returns (bool, uint256) {
        for (uint256 i = 0; i < users.length; i += 1) {
            if (user == users[i]) return (true, i);
        }
        return (false, 0);
    }

    /** @dev add a user to users array
     * @param user address of user to add to the list
     */

    function addUser(address user) internal {
        (bool _isUser, ) = isUser(user);
        if (!_isUser) users.push(user);
    }

    /** @dev remove a user from users array
     * @param user address of user to remove from the list
     */

    function removeUser(address user) internal {
        (bool _isUser, uint256 i) = isUser(user);
        if (_isUser) {
            users[i] = users[users.length - 1];
            users.pop();
        }
    }

    function showBlackUser(address user) external view onlyOwner returns (bool) {
        return _blackListed[user];
    }

    function addToBlackList(address user) external onlyOwner {
        _blackListed[user] = true;
    }

    function removeFromBlackList(address user) external onlyOwner {
        _blackListed[user] = false;
    }

    /** @dev stake funds to PoolContract
     */
    function Approvestake(uint256 amount) external whenNotPaused {
        // staking amount cannot be zero
        require(amount > 0, "cannot be zero");

        // Transfer Mock  tokens to this contract for staking
        MCHToken.transferFrom(msg.sender, address(this), amount);

        // updating stakedBalances
        stakedBalances[msg.sender] = stakedBalances[msg.sender].add(amount);

        // updating total stakedBalances
        uint256 shares = (stakedBalances[msg.sender].mul(100)).div(totalStakedMcH.add(amount));

        // updating stakedShares
        stakedShares[msg.sender] = stakedShares[msg.sender].add(shares);

        // Adding staker to users Array only if not staked early
        if (!Staked[msg.sender]) {
            addUser(msg.sender);

            // storing the start stake time of user
            creationTime[msg.sender] = block.timestamp;
        }

        // updating status of the staking
        isStaking[msg.sender] = true;
        Staked[msg.sender] = true;

        // triggering event
        emit NotifyStaked(msg.sender, amount);
    }
}
