import { ViewModel } from '../common/ViewModel';
import { POKE_TABLE } from '../db/PokeTable';
import { store } from '../db/RDB';
import { SplashConstants } from '../viewmodel/SplashConstants';
import {loadRdbStore} from '../db/RDB'

export class SplashViewModel extends ViewModel {

  async prepareWhileSplashShown(context: Context| undefined) {
    if (context != null) {
      this.backgroundTask(this.prepare(context))
    } else {
     console.error("context is null")
    }
  }

  private async prepare(context: Context) {
    await this.prepareTable(context)
    await this.sleep(2000)
    this.endSplash()
  }

  private async prepareTable(context: Context) {
    console.info('SplashVM-' + 'prepareTable');
    try {
      await loadRdbStore(context)
      await store.executeSql(POKE_TABLE.sqlCreate)
    } catch (e) {
      console.error(e)
    }
  }

  private endSplash() {
    try {
      const setResult = this.storage.set<boolean>(SplashConstants.SPLASH_END, true);
      console.log("setResult-" + setResult);
    } catch (e) {
      console.error(e)
    }
  }

  async sleep(msec: number): Promise<number> {
    return new Promise<number>(resolve => setTimeout(resolve, msec));
  }
}