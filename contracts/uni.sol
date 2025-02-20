const main = async () => {
  try {
    const theAddressIFoundWithUSDCAndDAI = "0xf8d437028b47e80afc7a8d4d38fc9ae0172d621";
    
    // Impersonate the account with USDC and DAI
    await helpers.impersonateAccount(theAddressIFoundWithUSDCAndDAI);
    const impersonatedSigner = await ethers.getSigner(theAddressIFoundWithUSDCAndDAI);
    
    // Get contract instances
    const usdcContract = await ethers.getContract("IERC20", USDCAddress);
    const daiContract = await ethers.getContract("IERC20", DAIAddress);
    const uniswapContract = await ethers.getContract("IUniswap", UNIRouter);
    
    // Get USDC balance
    const usdcBal = await usdcContract.balanceOf(impersonatedSigner.address);
    
    // Log the balance as a string and formatted
    console.log('Raw USDC balance:', usdcBal.toString());
    console.log('Impersonated acct USDC bal:', ethers.formatUnits(usdcBal, 6));
    
    // Get DAI balance
    const daiBal = await daiContract.balanceOf(impersonatedSigner.address);
    console.log('Raw DAI balance:', daiBal.toString());
    console.log('Impersonated acct DAI bal:', ethers.formatUnits(daiBal, 18));
    
    // Log account details
    console.log('Impersonated account address:', impersonatedSigner.address);
    
    // Optional: Check ETH balance
    const ethBal = await ethers.provider.getBalance(impersonatedSigner.address);
    console.log('ETH balance:', ethers.formatEther(ethBal));
    
  } catch (error) {
    console.error('Error in main function:');
    console.error(error);
    
    // Log more details if it's a contract-related error
    if (error.reason) {
      console.error('Error reason:', error.reason);
    }
    if (error.code) {
      console.error('Error code:', error.code);
    }
    if (error.transaction) {
      console.error('Failed transaction:', error.transaction);
    }
  }
};

// Execute main function
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });