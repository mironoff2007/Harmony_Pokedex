import router from '@ohos.router';
import { RouteConstants } from './RouteConstants';
import { SplashViewModel } from '../viewmodel/SplashViewModel';
import { SplashConstants } from '../viewmodel/SplashConstants';

const storage: LocalStorage = new LocalStorage();

@Entry(storage)
@Component
struct SplashScreen {
  private splashViewModel?: SplashViewModel

  @State message: string = 'Pokedex';

  @LocalStorageProp(SplashConstants.SPLASH_END)
  @Watch('onSplashEnd')
  splashEnd: boolean = false;

  // @Watch callback
  onSplashEnd(): void {
    if (this.splashEnd) {
      console.info('splashEnd');
      router.replaceUrl({ url: RouteConstants.POKE_LIST })
    }
  }

  aboutToAppear() {
    this.splashViewModel = new SplashViewModel(storage)
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
      if (this.splashViewModel != null) {
        this.splashViewModel.prepareWhileSplashShown(this.getUIContext().getHostContext())
      }
    })
  }
}
