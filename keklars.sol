pragma solidity ^0.4.24;

library safeMath
{
    function mul (uint a, uint b) internal pure returns (uint c) // Умножить
    {
        if (a == 0)
        {
            return 0;
        }
        
        c = a * b;
        assert (c / a == b);
        return c;
    }
    
    function div (uint a, uint b) internal pure returns (uint) // Разделить
    {
        return a / b;
    }
    
    function sub (uint a, uint b) internal pure returns (uint) // Отнять
    {
        assert (b <= a);
        return a - b;
    }
    
    function add (uint a, uint b) internal pure returns (uint c) // Прибавить
    {
        c = a + b;
        assert (c >= a);
        return c;
    }
}

contract Keklars
{
    using safeMath for uint;
    
    string public constant name = 'Smart-contract based KEKLARS'; //Имя токена
    string public constant symbol = 'KEK'; // Символ
    //uint8 public constant decimals = 0; // Количество чисел после запятой
    
    uint public totalSupply; // Общее предложение
    address public owner; // Адрес владельца токена
    
    mapping (address => uint) public balances; // Список баланса
    
    constructor () public
    {
        owner = msg.sender; // Тот кто развернул контракт тот им и владеет
    }
    
    event Transfer (address _from, address _to, uint _amount);
    
    /*function balanceOf (address _owner) public view returns (uint) // Баланс
    {
        return balances[_owner];
    }*/
    
    function transfer (address _to, uint _amount) public returns (bool) // Перечислить деньги на баланс
    {
        balances[msg.sender] = safeMath.sub (balances[msg.sender], _amount);
        balances[_to] = safeMath.add (balances[_to], _amount);
        return true;
    }
    
    function mint (address _to, uint _amount) public returns (uint) // Эмитирование монет
    {
        require (msg.sender == owner);
        totalSupply = safeMath.add (totalSupply, _amount);
        balances[_to] = safeMath.add (balances[_to], _amount);
        
        return balances[_to];
    }
}
