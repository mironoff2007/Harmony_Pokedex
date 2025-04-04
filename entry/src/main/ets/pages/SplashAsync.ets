import router from '@ohos.router';
import { RouteConstants } from './RouteConstants';
import { SplashViewModel } from '../viewmodel/SplashViewModel';
import { SplashConstants } from '../viewmodel/SplashConstants';

//let para: Record<string,boolean> = { 'splashEnd' : false };
const storage: LocalStorage = new LocalStorage();
const splashViewModel: SplashViewModel = new SplashViewModel(storage)

@Entry(storage)
@Component
struct SplashAsync {
  @State message: string = 'Pokedex';

  @LocalStorageProp('splashEnd')
  @Watch('onSplashEnd')
  splashEnd: boolean = false;

  // @Watch callback
  onSplashEnd(): void {
    if (this.splashEnd) {
      console.info('splashEnd');
      router.replaceUrl({ url: RouteConstants.POKE_LIST })
    }
  }

  build() {
    RelativeContainer() {
      if (this.splashEnd) {
        Text("End")
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .alignRules({
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
      }
      Text(this.message)
        .id(this.message)
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(() => {
          console.info('text click');
        })
    }
    .height('100%')
    .width('100%')
    .onAppear(() => {
      console.log('on appear')
      splashViewModel.prepareWhileSplashShown(this.getUIContext().getHostContext())
    })
  }
}
