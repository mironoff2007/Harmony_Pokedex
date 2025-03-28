import router from '@ohos.router'
import { ContentViewState, ViewState, ViewStateGeneric } from '../common/State';
import { Pokemon } from '../model/Pokemon';
import { PokeDetailParams } from '../viewmodel/pokedetail/PokeDetailParams'
import { PokeDetailState } from '../viewmodel/pokedetail/PokeDetailState';
import { PokeDetailViewModel } from '../viewmodel/pokedetail/PokeDetailViewModel';

const storage: LocalStorage = new LocalStorage();
const viewModel: PokeDetailViewModel = new PokeDetailViewModel(storage)

@Entry(storage)
@Component
struct PokeDetail {
  @State poke: Pokemon| null = null;
  @State err: Error| null = null;
  @State progressVal: number = 0;
  @State intervalLoading: number = -1;
  @State name: string = ''
  @LocalStorageProp('pokeDetailState')
  @Watch('onStateChange')
  state: ViewStateGeneric<PokeDetailState> = ViewState.loading;

  // @Watch callback
  onStateChange(): void {
    if (ViewState.isLoading(this.state)) {

    } else if (ViewState.isContent(this.state)) {
      console.info("content")
      const localState = this.state as ContentViewState<PokeDetailState>
      this.poke = localState.value.pokemon
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
          if(this.poke != null) {
            Image(this.poke.picUrl)
              .height(150)
              .objectFit(ImageFit.Fill)
            Text(this.poke.name)
              .fontSize(40)
              .fontWeight(FontWeight.Bold)
          }
        }
        .justifyContent(FlexAlign.Center)
        .height(120)
        .width('100%')

      }
      .height('100%')
      .width('100%')
    } else if (ViewState.isFailure(this.state)) {
      Stack({ alignContent: Alignment.Center }) {
        if (this.err != null) {
          Text("Error-" + this.err)
        }
      }.width('100%').height('100%')
    } else {

    }
  }
}