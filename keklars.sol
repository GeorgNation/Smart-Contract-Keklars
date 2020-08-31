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

contract Ownership
{
    address public owner; // Владелец
    
    event OwnershipTransfered (address from, address to); // Ивент при передачи владения
    
    constructor () public
    {
        owner = msg.sender; // Кто развернул тот и владеет
    }
    
    modifier onlyOwner () // Модификатор для отметки функций владельца
    {
        require (msg.sender == owner); // Требовать владельца
        _;
    }
    
    function transferOwnership (address _to) onlyOwner public returns (bool success) // Передать владение
    {
        owner = _to;
        emit OwnershipTransfered (msg.sender, _to);
        
        return true;
    }
}

contract Keklars is Ownership
{
    using safeMath for uint;
    
    struct Transaction
    {
        address from;   // Отправитель
        address to;     // Адресат получателя
        uint amount;    // Количество средств
        string comment; // Комментарий
        uint timestamp; // Время
        uint txType;  // Статус транзакции. 0 - Обычная транзакция. 1 - Делегирование монет. 2 - Передача делегированных монет
    }
    
    string constant public name = 'Smart-contract based KEKLARS'; //Имя токена
    string constant public symbol = 'KEK'; // Символ
    uint8 constant public decimals = 2; // Количество чисел после запятой
    
    uint public totalSupply; // Общее предложение
    //address public owner; // Адрес владельца токена
    
    uint public transactionCount; // Количество транзакций
    
    mapping (address => uint) balances;                     // Учетная книгв
    mapping (address => mapping (address => uint)) allowed; // Разрешенные средства
    mapping (uint => Transaction) public transactions;      // Транзакции
    
    /*constructor () public
    {
        owner = msg.sender; // Тот кто развернул контракт тот им и владеет
    }*/
    
    event TransferComment (address indexed _from, address indexed _to, uint _amount, string _comment); // Ивент при передаче монет
    event Transfer (address indexed _from, address indexed _to, uint _amount); // Ивент при передаче монет
    event Mint (address _to, uint _amount); // Ивент при эмитировании монет
    event OwnerChanged (address _to); // Смена владельца
    event Approval (address indexed _owner, address indexed _spender, uint _amount); // Делегирование прав на монеты
    
    function balanceOf (address _owner) public view returns (uint balance) // Баланс
    {
        return balances[_owner];
    }
    
    function transfer (address _to, uint _amount) public payable returns (bool success) // Перечислить деньги на баланс
    {
        require (_amount <= balances[msg.sender], "Insufficient funds.");
            
        balances[msg.sender] = safeMath.sub (balances[msg.sender], _amount);
        balances[_to] = safeMath.add (balances[_to], _amount);
        
        transactionCount = safeMath.add (transactionCount, 1);
        Transaction memory _tx = Transaction (msg.sender, _to, _amount, "NAN", now, 0);
        transactions[transactionCount] = _tx;
        
        emit Transfer (msg.sender, _to, _amount);
        
        return true;
    }
    
    function transferWithComment (address _to, uint _amount, string _comment) public payable returns (bool success, uint _txId) // Перечислить деньги на баланс и оставить комментарий
    {
        require (_amount <= balances[msg.sender], "Insufficient funds.");
        
        balances[msg.sender] = safeMath.sub (balances[msg.sender], _amount);
        balances[_to] = safeMath.add (balances[_to], _amount);
        
        transactionCount = safeMath.add (transactionCount, 1);
        Transaction memory _tx = Transaction (msg.sender, _to, _amount, _comment, now, 0);
        transactions[transactionCount] = _tx;
        
        emit TransferComment (msg.sender, _to, _amount, _comment);
        
        return (true, transactionCount);
    }
    
    function mint (address _to, uint _amount) onlyOwner public payable returns (bool success, uint _txId) // Эмитирование монет
    {
        _amount = _amount * 10**uint (decimals);
        
        totalSupply = safeMath.add (totalSupply, _amount);
        balances[_to] = safeMath.add (balances[_to], _amount);
        
        transactionCount = safeMath.add (transactionCount, 1);
        Transaction memory _tx = Transaction (msg.sender, _to, _amount, "Minted", now, 0);
        transactions[transactionCount] = _tx;
        
        emit Mint (_to, _amount);
        
        return (true, transactionCount);
    }
    
    function transferFrom (address _from, address _to, uint _amount) public payable returns (bool success, uint _txId) // Передать монеты
    {
        balances[_from] = safeMath.sub (balances[_from], _amount);
        allowed[_from][msg.sender] = safeMath.sub (allowed[_from][msg.sender], _amount);
        balances[_to] = safeMath.add (balances[_to], _amount);
        
        transactionCount = safeMath.add (transactionCount, 1);
        Transaction memory _tx = Transaction (msg.sender, _to, _amount, "Gived.", now, 2);
        transactions[transactionCount] = _tx;
        
        emit TransferComment (_from, _to, _amount, "Gived.");
        
        return (true, transactionCount);
    }
    
    function approve (address _spender, uint _amount) public returns (bool success) // Делегировать (передать права) монет
    {
        
        allowed[msg.sender][_spender] = safeMath.add (allowed[msg.sender][_spender], _amount);
        
        transactionCount = safeMath.add (transactionCount, 1) - 2;
        Transaction memory _tx = Transaction (msg.sender, _spender, _amount, "Delegated.", now, 1);
        transactions[transactionCount] = _tx;
        
        emit Approval (msg.sender, _spender, _amount);
        
        return true;
    }
    
    function allowance(address _owner, address _spender) public constant returns (uint remaining) // Узнать сколько передано монет
    {
        return allowed[_owner][_spender];
    }
    
    function completlyCloseContract () onlyOwner public // Удалить токен
    {
        uint balance = address (this).balance;
        address (owner).transfer (balance);
        selfdestruct (msg.sender);
    }
    
    function getPercent (uint part, uint whole) internal pure returns (uint percent)
    {
        uint numerator = part * 1000;
        require (numerator > part); // overflow. Should use SafeMath throughout if this was a real implementation. 
        uint temp = numerator / whole + 5; // proper rounding up
        return temp / 10;
    }
}

/*contract KYDRA is Keklars
{
    //using safeMath for uint;
    
    struct Market
    {
        string name;
        address owner;
        string ipfsLogoUrl;
        string description;
    }
    
    struct Product
    {
        uint marketId;
        string name;
        string description;
        uint priceForPiece;
        uint left;
        string ipfsLogoUrl;
    }
    
    string public constant nameMarketplace = "Kydra";
    string public constant ourIpfsLogoUrl = "";
    
    mapping (uint => Market) public markets;
    mapping (uint => Product) public products;
    mapping (uint => uint) marketBalance;
    
    uint public marketCount;
    uint public productCount;
    
    event MarketCreated (string indexed _name, string _ipfsLogoUrl);
    event ProductCreated (uint indexed _marketId, string _name, string _description, uint _price, uint _productCount, string _ipfsLogoUrl);
    event ProductPurchcased (address indexed _buyer, uint indexed _productId, uint _pieces);
    event ReservesReplenished (uint indexed _productId, uint _pieces);
    
    function createMarket (string _name, string _ipfsLogoUrl, string _description) public returns (bool success)
    {
        marketCount = marketCount.add (1);
        Market memory _temp_market = Market (_name, msg.sender, _ipfsLogoUrl, _description);
        markets[marketCount] = _temp_market;
        
        emit MarketCreated (_name, _ipfsLogoUrl);
        return true;
    }
    
    function createProduct (uint _marketId, string _name, string _description, uint _price, uint _productCount, string _ipfsLogoUrl) public returns (bool success, uint marketId)
    {
        require (markets[_marketId].owner == msg.sender);
        
        productCount = productCount.add (1);
        Product memory _temp_product = Product (_marketId, _name, _description, _price, _productCount, _ipfsLogoUrl);
        products[productCount] = _temp_product;
        
        emit ProductCreated (_marketId, _name, _description, _price, _productCount, _ipfsLogoUrl);
        
        return (true, productCount);
    }
    
    function buyProduct (uint _productId, uint _pieces) public payable returns (bool success, uint _txId)
    {
        require (products[_productId].left >= _pieces);
        require (balances[msg.sender] >= (products[_productId].priceForPiece * _pieces));
        
        balances[msg.sender] = balances[msg.sender].sub (products[_productId].priceForPiece * _pieces);
        balances[address (this)] = balances[address (this)].add (products[_productId].priceForPiece * _pieces);
        
        marketBalance[products[_productId].marketId] = marketBalance[products[_productId].marketId].add (products[_productId].priceForPiece * _pieces);
        
        transactionCount = safeMath.add (transactionCount, 1);
        Transaction memory _tx = Transaction (msg.sender, address (this), products[_productId].priceForPiece * _pieces, append ("Buyed product in KYDRA shop ", markets[products[_productId].marketId].name, "."), now, 0);
        transactions[transactionCount] = _tx;
        
        emit Transfer (msg.sender, address (this), products[_productId].priceForPiece * _pieces, append ("Buyed product in KYDRA shop ", markets[products[_productId].marketId].name, "."));
        
        emit ProductPurchcased (msg.sender, _productId, _pieces);
        
        return (true, transactionCount);
    }
    
    function addPiecesForProduct(uint _productId, uint _pieces) public returns (bool success)
    {
        require (markets[products[_productId].marketId].owner == msg.sender);
        
        products[_productId].left = safeMath.add (products[_productId].left, _pieces);
        
        emit ReservesReplenished (_productId, _pieces);
        
        return true;
    }
    
    function append(string a, string b, string c) internal pure returns (string) {
    
        return string(abi.encodePacked(a, b, c));
    
    }
}*/
