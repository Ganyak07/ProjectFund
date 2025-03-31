import { describe, expect, it } from "vitest";
import { uintCV, trueCV, falseCV, stringAsciiCV, stringUtf8CV, standardPrincipalCV } from "@stacks/transactions";

// Define dummy addresses
const dummyAddress1 = "ST2JX41F8S6Y7Q1Z1X1X1X1X1X1X1X1X1X1X1X1X1X1X1X1X1X1X1X";
const dummyAddress2 = "ST3JX41F8S6Y7Q1Z1X1X1X1X1X1X1X1X1X1X1X1X1X1X1X1X1X1X1X";

const contractName = "ProFunding";

describe("ProFunding Smart Contract Tests", () => {
  it("ensures simnet is well initialized", () => {
    expect(simnet.blockHeight).toBeDefined();
  });

  it("should activate the contract", () => {
    const { result } = simnet.callPublicFn(
      contractName,
      "activate-contract",
      [],
      dummyAddress1
    );
    expect(result).toBeOk(trueCV());
  });

  it("should onboard a new member", () => {
    const { result } = simnet.callPublicFn(
      contractName,
      "onboard-new-member",
      [standardPrincipalCV(dummyAddress2)],
      dummyAddress1
    );
    expect(result).toBeOk(trueCV());
  });

  it("should fail to onboard an existing member", () => {
    const { result } = simnet.callPublicFn(
      contractName,
      "onboard-new-member",
      [standardPrincipalCV(dummyAddress2)],
      dummyAddress1
    );
    expect(result).toBeErr(uintCV(3)); // error-invalid-input
  });

  it("should register a new project", () => {
    const { result } = simnet.callPublicFn(
      contractName,
      "register-project",
      [
        stringAsciiCV("Test Project"),
        stringUtf8CV("This is a test project description."),
        uintCV(1000),
        uintCV(2000)
      ],
      dummyAddress2
    );
    expect(result).toBeOk(uintCV(1)); // Assuming this is the first project
  });

  it("should cast a vote on a project", () => {
    const { result } = simnet.callPublicFn(
      contractName,
      "cast-vote",
      [uintCV(1), trueCV()],
      dummyAddress1
    );
    expect(result).toBeOk(trueCV());
  });

  it("should contribute funds to a project", () => {
    const { result } = simnet.callPublicFn(
      contractName,
      "contribute-funds",
      [uintCV(1), uintCV(500)],
      dummyAddress1
    );
    expect(result).toBeOk(trueCV());
  });

  it("should get project details", () => {
    const { result } = simnet.callReadOnlyFn(
      contractName,
      "get-project-details",
      [uintCV(1)],
      dummyAddress1
    );
    expect(result).toBeSome();
  });

  it("should get member profile", () => {
    const { result } = simnet.callReadOnlyFn(
      contractName,
      "get-member-profile",
      [standardPrincipalCV(dummyAddress2)],
      dummyAddress1
    );
    expect(result).toBeSome();
  });

  it("should withdraw funds from a project", () => {
    // Advance the block height to simulate the deadline passing
    simnet.mineEmptyBlocks(2001);

    const { result } = simnet.callPublicFn(
      contractName,
      "withdraw-funds",
      [uintCV(1)],
      dummyAddress2
    );
    expect(result).toBeOk(trueCV());
  });

  it("should offboard a member", () => {
    const { result } = simnet.callPublicFn(
      contractName,
      "offboard-member",
      [standardPrincipalCV(dummyAddress2)],
      dummyAddress1
    );
    expect(result).toBeOk(trueCV());
  });
});