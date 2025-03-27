import router from '@ohos.router'
import { ViewState } from '../common/State';
import { PokeDetailParams } from '../viewmodel/pokedetail/PokeDetailParams'
import { PokeDetailState } from '../viewmodel/pokedetail/PokeDetailState';
import { PokeDetailViewModel } from '../viewmodel/pokedetail/PokeDetailViewModel';

const storage: LocalStorage = new LocalStorage();
const viewModel: PokeDetailViewModel = new PokeDetailViewModel(storage)

@Entry(storage)
@Component
struct PokeDetail {
  @State progressVal: number = 0;
  @State intervalLoading: number = -1;
  @State name: string = ''
  @LocalStorageProp('pokeDetailState')
  @Watch('onStateChange')
  state: ViewState<PokeDetailState> = ViewState.loading;

  // @Watch callback
  onStateChange(): void {
    if (ViewState.isLoading(this.state)) {

    } else if (ViewState.isContent(this.state)) {
      console.info("content")
    }
  }

  aboutToAppear() {
    this.intervalLoading = setInterval(() => {
      this.progressVal = this.progressVal >= 100 ?
        0 : (this.progressVal + 5);
    }, 50);
    const pokeDetailParam = router.getParams() as PokeDetailParams
    viewModel.getPokemon(pokeDetailParam.name)
  }

  build() {
    if (ViewState.isLoading(this.state)) {
      Stack({ alignContent: Alignment.Center }) {
        Progress({ value: 0, total: 100, type: ProgressType.Ring })
          .width(100)
          .value(this.progressVal)
      }.width('100%').height('100%')
    } else if (ViewState.isContent(this.state)) {
      Stack() {
        Column() {
          Image(this.state.value.pokemon.picUrl)
            .height(150)
            .objectFit(ImageFit.Fill)
          Text(this.state.value.pokemon.name)
            .fontSize(40)
            .fontWeight(FontWeight.Bold)
        }
        .justifyContent(FlexAlign.Center)
        .height(120)
        .width('100%')

      }
      .height('100%')
      .width('100%')
    } else if (ViewState.isFailure(this.state)) {
      Stack({ alignContent: Alignment.Center }) {
        Text("Error-" + this.state.error)
      }.width('100%').height('100%')
    } else {

    }
  }
}