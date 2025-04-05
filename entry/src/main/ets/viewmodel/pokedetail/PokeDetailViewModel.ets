import { PokeDetailState } from './PokeDetailState';
import { ContentViewState, FailureViewState, ViewState } from '../../common/State';
import { PokeRepo } from '../../db/PokeRepo';
import { ViewModel } from '../../common/ViewModel';
import { Pokemon } from '../../model/Pokemon';
import { PokeDetailConstants } from './PokeDetailConstants';

export class PokeDetailViewModel extends ViewModel {
  LOG_TAG: string = "PokeDetailViewModel-"

  pokeRepo = new PokeRepo();

  private setError(e: Error) {
    try {
      const setResult = this.storage.set<FailureViewState>(PokeDetailConstants.POKE_DETAIL_STATE_KEY, ViewState.failure(e));
      console.log("setResult-" + setResult);
    } catch (e) {
      console.error(e)
    }
  }

  getPokemon(name: string) {
    this.backgroundTask(this.getPokemonTask(name))
  }

  private async getPokemonTask(name: string) {
    try {
      const poke:Pokemon = await this.pokeRepo.getByName(name)
      const pokeDetailState: PokeDetailState = { pokemon: poke };
      const setResult = this.storage.set<ContentViewState<PokeDetailState>>(
        PokeDetailConstants.POKE_DETAIL_STATE_KEY,
        ViewState.content(pokeDetailState)  // Wrap in PokeDetailState
      );
      console.log("setResult-" + setResult);
    } catch (e) {
      this.setError(e)
      console.error(this.LOG_TAG + `error get: ${e}`);
    }
  }

}