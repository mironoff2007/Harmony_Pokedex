import { PokeDetailState } from './PokeDetailState';
import { ContentViewState, ViewState, ViewStateGeneric } from '../../common/State';
import { PokeRepo } from '../../db/PokeRepo';
import { Pokemon } from '../../model/Pokemon';
import { ViewModelV2 } from '../../common/ViewModelV2';

@ObservedV2
export class PokeDetailViewModel extends ViewModelV2<PokeDetailState> {
  LOG_TAG: string = "PokeDetailViewModel-"
  pokeRepo = new PokeRepo();

  private setError(e: Error) {
    try {
      this.state = ViewState.failure(e);
      console.log("setResult-" + e);
    } catch (e) {
      console.error(e)
    }
  }

  getPokemon(name: string) {
    this.backgroundTask(this.getPokemonTask(name))
  }

  private async getPokemonTask(name: string) {
    try {
      const poke: Pokemon = await this.pokeRepo.getByName(name)
      const pokeDetailState: PokeDetailState = { pokemon: poke };
      this.state = ViewState.content(pokeDetailState)
      console.log("setResult-" + pokeDetailState);
    } catch (e) {
      this.setError(e)
      console.error(this.LOG_TAG + `error get: ${e}`);
    }
  }
}