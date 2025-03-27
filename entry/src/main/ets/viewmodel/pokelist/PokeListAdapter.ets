import ArrayList from '@ohos.util.ArrayList';
import { BasicDataSource } from '../../common/BasicDataSource';
import { Pokemon } from '../../model/Pokemon';

export class PokeListAdapter extends BasicDataSource<Pokemon>  {
  private dataArray: ArrayList<Pokemon> = new ArrayList();

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getData(index: number): Pokemon {
    return this.dataArray[index];
  }

  public updateRangeData(data: ArrayList<Pokemon>): void {
    for (let i = 0; i < data.length; i++) {
      const poke = data[i];
      if (poke) {
        this.updateData(poke.id, poke);
      }
    }
  }

  public updateData(index: number, data: Pokemon): void {
    console.debug("update-" + data.name);
    this.dataArray[index] = data; // Use modify instead of splice
    this.notifyDataChange(index);
  }

  public addAllData(array: Pokemon[]): void {
    this.dataArray.clear(); // Use clear() instead of splice

    for (let i = 0; i < array.length; i++) {
      const pokemon = array[i];
      if (pokemon) {
        this.dataArray.add(pokemon); // Use add() instead of push
      }
    }
    this.notifyDataReload();
  }
}
