import { POKE_TABLE } from '../db/PokeTable';
import relationalStore from '@ohos.data.relationalStore'

export class Pokemon {
  id: number;
  name: string;
  url: string;
  picUrl: string;
  time: number

  constructor(id: number, name: string, url: string, picUrl: string, time: number) {
    this.id = id;
    this.name = name;
    this.url = url;
    this.picUrl = picUrl;
    this.time = time;
  }
}


interface PokemonBucket {
  name?: string;
  url?: string;
  picUrl?: string;
  time?: number;
  // Add other properties from POKE_TABLE.columns except 'id'
}
export function generateBucket(poke: Pokemon): relationalStore.ValuesBucket {
  const obj: PokemonBucket = {};
  POKE_TABLE.columns.forEach((item) => {
    if (item !== 'id') {
      obj.name = poke.name;
      obj.url = poke.url;
      obj.picUrl = poke.picUrl;
      obj.time = poke.time;
    }
  });
  return obj as relationalStore.ValuesBucket;
}