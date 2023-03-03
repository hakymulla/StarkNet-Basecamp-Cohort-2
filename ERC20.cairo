#[contract]
mod ERC20 {

    use starknet::get_caller_address;

    struct Storage {
    owner: felt,
    name: felt,
    symbol: felt,
    decimals: u8,
    total_supply: u256,
    balances: LegacyMap::<felt, u256>,
    allowances: LegacyMap::<(felt, felt), u256>
    }

    #[event]
    fn Transfer(from: felt, to: felt, value: u256) {}

    #[event]
    fn Approval(sender: felt, recipient: felt, value: u256) {}

    #[constructor]
    fn constructor(_name: felt, _symbol: felt, _decimals: u8) {
        name::write(_name);
        symbol::write(_symbol);
        decimals::write(_decimals);
        owner::write(get_caller_address());
    }

    #[view]
    fn get_owner() -> felt {
        owner::read()
    }
    #[view]
    fn get_name() -> felt {
        name::read()
    }

    #[view]
    fn get_symbol() -> felt {
        symbol::read()
    }

    #[view]
    fn get_decimals() -> u8 {
        decimals::read()
    }

    #[view]
    fn get_total_supply() -> u256 {
        total_supply::read()
    }

    #[view]
    fn get_balances(address: felt) -> u256 {
        balances::read(address)
    }

    #[view]
    fn get_allowances(sender: felt, recipient: felt) -> u256 {
        allowances::read((sender, recipient))
    }

     #[external]
    fn transfer(address: felt, amount: u256) -> bool {
        let caller = get_caller_address();
        let sender_balance = balances::read(get_caller_address());
        balances::write(caller, sender_balance - amount);
        balances::write(address, amount);
        Transfer(caller, address, amount);
        true

    }

    #[external]
    fn approve(spender: felt, amount: u256) -> bool {
      let caller = get_caller_address();
      allowances::write((caller, spender), amount);
      Approval(caller, spender, amount);
      true

    }

    #[external]
    fn transferFrom(sender: felt, recipient: felt, amount: u256) -> bool {
      let allowed = allowances::read((sender, recipient));
      // assert(0_u256 >= allowed, 'Not Enough'); //ge
      assert(allowed >= amount, 'Extra'); //ge
      allowances::write((sender, recipient), amount-allowed);

      balances::write(sender, balances::read(sender)-amount);
      balances::write(recipient, balances::read(recipient)+amount);

      Transfer(sender, recipient, amount);
      true
    }

    #[external]
    fn mint(amount: u256)  {
        let caller = get_caller_address();
        assert(get_owner() == caller, 'Only Owner');
        balances::write(caller, balances::read(caller) + amount);
        total_supply::write(amount);
        Transfer(0, caller, amount);
    }

    #[external]
    fn burn(amount: u256)  {
        let caller = get_caller_address();
        assert(get_owner() == caller, 'Only Owner');
        balances::write(caller, balances::read(caller) - amount);
        total_supply::write(amount);
        Transfer(caller, 0, amount);
    }
   
}



// cargo run --bin starknet-compile -- src/ERC20.cairo src/ERC20.sierra --replace-ids
// cargo run --bin starknet-sierra-compile -- src/ERC20.sierra src/ERC20.casm