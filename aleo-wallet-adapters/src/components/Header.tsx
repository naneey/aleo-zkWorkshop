import ConnectWalletButton from "./ConnectWallet";

const Header = () => {
  return (
    <div className="flex justify-between items-center px-16 py-4 bg-gray-800">
      <div>
        <h1 className="text-2xl font-bold text-white">My Finance</h1>
      </div>
      <ConnectWalletButton />
    </div>
  );
};

export default Header;
