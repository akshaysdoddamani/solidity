// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

contract wallet
{
    address  payable public owner;
    mapping (address => uint) public allowance  ;
    mapping (address => bool) public isallowed ;
    mapping (address => bool) public gaurdens;
    mapping (address => mapping (address=>bool)) votedfornewowner;

    address payable public next_owner;
    uint gardienrestcount;
    uint public constant resetgadiencount = 3;

    constructor()
    {
        owner = payable (msg.sender);
    }

    function resetowner(address payable newowner) public 
    {
        require(gaurdens[msg.sender],"You are not a gaurdien to set a new owner");
        require(votedfornewowner[newowner][msg.sender]==false,"You have already voted");
        if(newowner!=next_owner)
        {
            next_owner = newowner;
            gardienrestcount = 0;
        }
        gardienrestcount ++;
        if(gardienrestcount == resetgadiencount)
        {
            owner = next_owner;
            next_owner = payable(address(0));
        }
    }

    function setgaurdens(address abc,bool isgaurden) public 
    {
        require(msg.sender == owner,"You are not the owner to set the gaurden");
        gaurdens[abc] = isgaurden;
    }

    function allow(address abc, uint amount) public 
    {
        require(msg.sender == owner,"You are not a owner to allow a user");
        allowance[abc]= amount;
        if (amount > 0)
        {
            isallowed[abc] = true;
        }
        else 
        {
            isallowed[abc] = false;
        }
    }

    function pay(address payable to,uint amount,bytes memory payload) payable public returns (bytes memory)
    {
        //require(msg.sender == owner,"You are not a owner to pay from this wallet");
        if (msg.sender != owner)
        {
            require(allowance[msg.sender]>=amount,"Amount entered is greater than your wallet balance");
            require(isallowed[msg.sender] == true , "You are not allowed to send treansefr money from the wallet");

        }
        (bool success , bytes memory returndata)=to.call{value:amount}(payload);
        require (success,"Call was not successfull");
        return returndata;
    } 

    receive() external payable { }
}