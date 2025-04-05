import { ContentViewState, FailureViewState, ViewState, ViewStateFactoryType, ViewStateGeneric } from '../common/State';
import { Pokemon } from '../model/Pokemon';
import { PokeListViewModel } from '../viewmodel/pokelist/PokeListViewModel';
import { PokeListState } from '../viewmodel/pokelist/PokeListState';
import { RouteConstants } from './RouteConstants';
import router from '@ohos.router';
import { PokeDetailParams } from '../viewmodel/pokedetail/PokeDetailParams';
import { PokeListAdapter } from '../viewmodel/pokelist/PokeListAdapter';
import { PokeListConstants } from '../viewmodel/pokelist/PokeListConstants';

let storage: LocalStorage = new LocalStorage();

@Entry(storage)
@Component
struct PokeListPage {
  private pokeListViewModel?: PokeListViewModel;

  @State message: string = 'PokeListPage';
  @State progressVal: number = 0;
  @State isLoading: boolean = true;
  @State intervalLoading: number = -1;

  @LocalStorageProp(PokeListConstants.POKE_LIST_STATE_KEY)
  @Watch('onStateChange')
  state: ViewStateGeneric<PokeListState> = ViewState.loading;

  @LocalStorageProp('pokeUpdate')
  @Watch('onPokeUpdate')
  updatePokemon: Pokemon | null = null;

  private listAdapter: PokeListAdapter = new PokeListAdapter();
  private error: Error | null = null;

  // @Watch callback
  onStateChange(): void {
    if (ViewState.isLoading(this.state)) {

    } else if (ViewState.isContent(this.state)) {
      const localState = this.state as ContentViewState<PokeListState>
      localState.value.pokemonsList.length
      this.listAdapter.addAllData(localState.value.pokemonsList)
    } else if (ViewState.isFailure(this.state)) {
      const localState = this.state as FailureViewState
      this.error = localState.error
    }
  }

  // @Watch callback
  onPokeUpdate(): void {
    if (this.updatePokemon != null) {
      this.listAdapter.updateData(this.updatePokemon.id, this.updatePokemon)
    }
  }

  aboutToAppear() {
    this.pokeListViewModel = new PokeListViewModel(storage)
    this.pokeListViewModel.getPokemons()
    this.intervalLoading = setInterval(() => {
      this.progressVal = this.progressVal >= 100 ?
        0 : (this.progressVal + 5);
    }, 50);
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
    } else if (ViewState.isFailure(this.state)) {
      Stack({ alignContent: Alignment.Center }) {
        if (this.error != null) {
          Text("Error-" + this.error.message)
        }
      }.width('100%').height('100%')
    } else {

    }
  }
}