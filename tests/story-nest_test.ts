import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Test story creation",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const frames = [1, 2, 3].map(n => types.uint(n));
    
    let block = chain.mineBlock([
      Tx.contractCall('story-nest', 'create-story',
        [
          types.utf8("Test Story"),
          types.utf8("Test Description"),
          types.list(frames)
        ],
        deployer.address
      )
    ]);
    
    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectOk().expectUint(0);
    
    const response = chain.callReadOnlyFn(
      'story-nest',
      'get-story-details',
      [types.uint(0)],
      deployer.address
    );
    
    const story = response.result.expectOk().expectSome();
    assertEquals(story.get('title'), "Test Story");
  }
});

Clarinet.test({
  name: "Test story liking",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const user1 = accounts.get('wallet_1')!;
    const frames = [1, 2, 3].map(n => types.uint(n));
    
    // Create story
    let block = chain.mineBlock([
      Tx.contractCall('story-nest', 'create-story',
        [
          types.utf8("Test Story"),
          types.utf8("Test Description"),
          types.list(frames)
        ],
        deployer.address
      )
    ]);
    
    // Like story
    block = chain.mineBlock([
      Tx.contractCall('story-nest', 'like-story',
        [types.uint(0)],
        user1.address
      )
    ]);
    
    block.receipts[0].result.expectOk().expectBool(true);
    
    // Verify like
    const response = chain.callReadOnlyFn(
      'story-nest',
      'has-liked-story',
      [types.uint(0), types.principal(user1.address)],
      deployer.address
    );
    
    response.result.expectOk().expectBool(true);
  }
});
