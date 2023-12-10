import "@nomiclabs/hardhat-ethers";
import { ethers } from "hardhat";

async function main() {
  const verifier = await ethers.deployContract("Verifier");
  await verifier.waitForDeployment();

  const _verifierAddress = verifier.getAddress();

  const appId = BigInt(
    "547981702587044957664170598089292540963614359552"
  ).toString();

  const anonAadhaarVerifier = await ethers.deployContract(
    "AnonAadhaarVerifier",
    [_verifierAddress, appId]
  );
  await anonAadhaarVerifier.waitForDeployment();

  const _anonAadhaarVerifierAddress = anonAadhaarVerifier.getAddress();

  const stream = await ethers.deployContract("Streamer", [
    "Would you like to crowdfund for the needy, whom and where would you like fund",
    [&input1,&input2,&input3],
    _anonAadhaarVerifierAddress,
  ]);

  await stream.waitForDeployment();

  console.log(`Streamer contract deployed to ${await stream.getAddress()}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
