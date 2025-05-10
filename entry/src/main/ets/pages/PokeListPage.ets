import { ContentViewState, FailureViewState, ViewState, ViewStateFactoryType, ViewStateGeneric } from '../common/State';
import { Pokemon } from '../model/Pokemon';
import { PokeListViewModel } from '../viewmodel/pokelist/PokeListViewModel';
import { RouteConstants } from './RouteConstants';
import router from '@ohos.router';
import { PokeDetailParams } from '../viewmodel/pokedetail/PokeDetailParams';
import { PokeListAdapter } from '../viewmodel/pokelist/PokeListAdapter';

@Entry()
@ComponentV2
struct PokeListPage {
  private listAdapter: PokeListAdapter = new PokeListAdapter();
  private pokeListViewModel: PokeListViewModel = new PokeListViewModel(this.listAdapter);
  @Local message: string = 'PokeListPage';
  @Local progressVal: number = 0;
  @Local isLoading: boolean = true;
  @Local intervalLoading: number = -1;

  aboutToAppear() {
    //this.pokeListViewModel = new PokeListViewModel(this.listAdapter)
    this.pokeListViewModel.getPokemons()
    this.intervalLoading = setInterval(() => {
      this.progressVal = this.progressVal >= 100 ?
        0 : (this.progressVal + 5);
    }, 50);
  }

  build() {
    if (ViewState.isLoading(this.pokeListViewModel.state)) {
      Stack({ alignContent: Alignment.Center }) {
        Progress({ value: 0, total: 100, type: ProgressType.Ring })
          .width(100)
          .value(this.progressVal)
      }.width('100%').height('100%')
    } else if (ViewState.isContent(this.pokeListViewModel.state)) {
      Stack() {
        List() {
          LazyForEach(this.listAdapter, (item: Pokemon) => {
            ListItem() {
              if (item.picUrl.length != 0) {
                Row() {
                  Text(item.name)
                    .fontSize(40)
                    .fontWeight(FontWeight.Bold)
                  Image(item.picUrl)
                    .height(120)
                    .objectFit(ImageFit.Fill)
                }
                .alignItems(VerticalAlign.Center)
                .justifyContent(FlexAlign.Center)
                .onClick(() => {
                  console.info("click poke-" + item.name)
                  const params: PokeDetailParams = { name: item.name }
                  router.pushUrl({ url: RouteConstants.POKE_DETAILS, params: params })
                })
              } else {
                Row() {
                  Text(item.name)
                    .fontSize(40)
                    .fontWeight(FontWeight.Bold)
                  Progress({ value: 0, total: 100, type: ProgressType.Ring })
                    .width(20)
                    .value(this.progressVal)
                }
                .alignItems(VerticalAlign.Center)
                .justifyContent(FlexAlign.Center)
                .onAppear(() => {
                  console.info("draw-" + item.name)
                  if (item.picUrl == "") {
                    this.pokeListViewModel.getPokeInfo(item)
                  }
                })
              }
            }
            .height(120)
            .width('100%')
          }, (item: Pokemon, index) => index + JSON.stringify(item));
        }
        .width('100%')
        .height('100%')
        .divider({
          strokeWidth: '0.5vp',
          color: '#0D000000'
        })
      }
      .height('100%')
      .width('100%')
    } else if (ViewState.isFailure(this.pokeListViewModel.state)) {
      Stack({ alignContent: Alignment.Center }) {
          Text("Error-" + this.pokeListViewModel.getError())
      }.width('100%').height('100%')
    } else {

    }
  }
}