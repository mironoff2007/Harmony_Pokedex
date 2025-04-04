import relationalStore from '@ohos.data.relationalStore'
import UIAbility from '@ohos.app.ability.UIAbility'

export let store: relationalStore.RdbStore;

const config: relationalStore.StoreConfig = {
  name: 'pokemon.db',
  securityLevel: relationalStore.SecurityLevel.S1
}

export function loadRdbStore(context: Context): Promise<relationalStore.RdbStore> {
  return new Promise((resolve, reject) => {
    relationalStore.getRdbStore(context, config, async (err, rdbStore) => {
      store = rdbStore;
      if (err) {
        console.error(`Get RdbStore failed, err: ${err}`);
        reject(err)
        return;
      }
      console.info(`Get RdbStore successfully.`);
      resolve(store)
    })
  })
}