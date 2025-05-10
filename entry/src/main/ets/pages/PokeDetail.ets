import router from '@ohos.router'
import { ContentViewState, ViewState, ViewStateGeneric } from '../common/State';
import { Pokemon } from '../model/Pokemon';
import { PokeDetailParams } from '../viewmodel/pokedetail/PokeDetailParams'
import { PokeDetailState } from '../viewmodel/pokedetail/PokeDetailState';
import { PokeDetailViewModel } from '../viewmodel/pokedetail/PokeDetailViewModel';


@Entry()
@ComponentV2
struct PokeDetail {
  @Param viewModel: PokeDetailViewModel = new PokeDetailViewModel();

  @Local progressVal: number = 0;
  @Local intervalLoading: number = -1;


  @Monitor("viewModel.state")
  onChange(monitor: IMonitor) {
    this.onStateChange(monitor.value()?.now as ViewStateGeneric<PokeDetailState>)
  }

  onStateChange(state: ViewStateGeneric<PokeDetailState>): void {
    //do something non UI on state change
  }

  aboutToAppear() {
    this.intervalLoading = setInterval(() => {
      this.progressVal = this.progressVal >= 100 ?
        0 : (this.progressVal + 5);
    }, 50);
    const pokeDetailParam = router.getParams() as PokeDetailParams
    //this.viewModel = new PokeDetailViewModel()
    this.viewModel.getPokemon(pokeDetailParam.name)
  }

  build() {
    if (ViewState.isLoading(this.viewModel.state)) {
      Stack({ alignContent: Alignment.Center }) {
        Progress({ value: 0, total: 100, type: ProgressType.Ring })
          .width(100)
          .value(this.progressVal)
      }.width('100%').height('100%')
    } else if (ViewState.isContent(this.viewModel.state)) {
      Stack() {
        Column() {
          if(this.viewModel.getContentState() != null) {
            Image(this.viewModel.getContentState()!!.pokemon.picUrl)
              .height(150)
              .objectFit(ImageFit.Fill)
            Text(this.viewModel.getContentState()!!.pokemon.name)
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
    } else if (ViewState.isFailure(this.viewModel.state)) {
      Stack({ alignContent: Alignment.Center }) {
        if (this.viewModel.getErrorState() != null) {
          Text("Error-" + this.viewModel.getErrorState()!!)
        }
      }.width('100%').height('100%')
    } else {

    }
  }
}