import { ViewModel } from '../common/ViewModel';
import { POKE_TABLE } from '../db/PokeTable';
import { store } from '../db/RDB';
import { SplashConstants } from '../viewmodel/SplashConstants';

export class SplashViewModel extends ViewModel {

  async prepareWhileSplashShown() {
    this.backgroundTask(this.prepare())
  }

  private async prepare() {
    await this.prepareTable()
    await this.sleep(2000)
    this.endSplash()
  }

  private async prepareTable(){
    console.info('SplashVM-' + 'prepareTable');
    await store.executeSql(POKE_TABLE.sqlCreate)
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