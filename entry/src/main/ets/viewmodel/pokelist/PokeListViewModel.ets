
import { generateBucket, Pokemon } from '../../model/Pokemon';
import { PokemonResponse } from '../../model/PokemonResponse';
import ArrayList from '@ohos.util.ArrayList';
import { ContentViewState, FailureViewState, LoadingViewState, ViewState } from '../../common/State';
import { PokeInfo, PokemonInfoResponse } from '../../model/PokemonInfoResponse';
import { PokeListState } from './PokeListState';
import { PokeRepo } from '../../db/PokeRepo';
import { AsyncCallback, BusinessError } from '../../common/AsyncCallback';
import { ViewModel } from '../../common/ViewModel';
import { PokeListConstants } from './PokeListConstants';

export class PokeListViewModel extends ViewModel {

  LOG_TAG: string = "PokeListViewModel-"
  pokeRepo = new PokeRepo();

  getPokemons() {
    this.setLoading()
    this.backgroundTask(this.getPokemonsTask())
  }

  updatePoke(json: string, poke: Pokemon) {
    this.backgroundTask(this.updatePokeTask(json, poke))
  }

  getPokeInfo(poke: Pokemon) {
    class GetPokeInfoCallback extends AsyncCallback<string, Error> {
      onCallback(err: BusinessError<Error> | null, json: string | null): void {
        if (json !== null) {
          new Promise<void>((resolve, reject) => { // Explicitly specify Promise<void>
            try {
              (this.parent as PokeListViewModel).updatePoke(json, poke);
              resolve();
            } catch (error) {
              reject(error);
            }
          });
        }
      }
    }

    const callback = new GetPokeInfoCallback(this)
    this.pokeRepo.getPokeInfo(poke, callback)
  }

  private setContent(pokemons: ArrayList<Pokemon>) {
    console.info(this.LOG_TAG + "setContent");
    try {
      let counter = 0
      for (let i = 0; i < pokemons.length; i++) {
        const poke = pokemons[i]; // Get element at index
        poke.id = counter++;
      }
      let setResult = false
      const pokemonArray = Array.from(pokemons)
      const state: PokeListState = { pokemonsList: pokemonArray }
      setResult = this.storage.set<ContentViewState<PokeListState>>(PokeListConstants.POKE_LIST_STATE_KEY, ViewState.content(state));
      console.log("setResult-" + setResult);
    } catch (e) {
      this.setError(e)
      console.error(e)
    }
  }

  private async updateContent(pokemon: Pokemon) {
    console.info(this.LOG_TAG + "updateContent");
    try {
      let setResult = false
      setResult = this.storage.set<Pokemon>("pokeUpdate", pokemon);
      console.log("setResult-" + setResult);
    } catch (e) {
      this.setError(e)
      console.error(e)
    }
  }

  private setError(e: Error) {
    try {
      const setResult = this.storage.set<FailureViewState>(PokeListConstants.POKE_LIST_STATE_KEY, ViewState.failure(e));
      console.log("setResult-" + setResult);
    } catch (e) {
      console.error(e)
    }
  }

  private setLoading() {
    try {
      const setResult = this.storage.set<LoadingViewState>(PokeListConstants.POKE_LIST_STATE_KEY, ViewState.loading);
      console.log("setResult-" + setResult);
    } catch (e) {
      console.error(e)
    }
  }

  private async getPokemonsTask() {
    try {
      if (await this.pokeRepo.count() != 0) {
        console.info(this.LOG_TAG + "load from db")
        const pokeList = await this.pokeRepo.getAll()
        this.setContent(pokeList)
      } else {
        console.info(this.LOG_TAG + "load from server")
        this.callPokemonsFromServer()
      }
    } catch (e) {
      this.setError(e)
      console.error(this.LOG_TAG + `error get: ${e}`);
    }
  }

  private async updatePokeTask(json: string, poke: Pokemon) {
    const pokeInfo: PokemonInfoResponse = JSON.parse(json)
    try {
      poke.picUrl = PokeInfo.getFrontSprite(pokeInfo.sprites)
    } catch (e) {
      console.error(e)
    }
    await this.pokeRepo.updateData(poke)
    this.updateContent(poke)
  }


  private callPokemonsFromServer(): void {
    class CallPokemonsFromServerCallback extends AsyncCallback<string, Error> {
      onCallback(err: BusinessError<Error> | null, data: string | null): void {
        if (err) {
          (this.parent as PokeListViewModel).setError(err);
          return;
        }

        if (data) {
          try {
            const pokemonResponse: PokemonResponse = JSON.parse(data);
            (this.parent as PokeListViewModel).savePokemonsToDb(pokemonResponse.results);
          } catch (parseError) {
            (this.parent as PokeListViewModel).setError(new BusinessError(null, (parseError as Error).message));
          }
        }
      }
    }

    const callPokemonsFromServerCallback = new CallPokemonsFromServerCallback(this)
    this.pokeRepo.callPokemonsFromServer(callPokemonsFromServerCallback);
  }

  async savePokemonsToDb(pokemons: Pokemon[] | null) {
    try {
      if (pokemons != null) {
        await this.pokeRepo.insertAll(pokemons)
        this.setContent(await this.pokeRepo.getAll())
      }
    } catch (e) {
      this.setError(e)
      console.error(e)
    }
  }

}

