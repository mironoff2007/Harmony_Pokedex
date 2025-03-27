export interface PokemonInfoResponse {
  sprites: Sprites;
}

export interface Sprites {
  front_default: string;
}

export interface IPokeInfo {
  getFrontSprite: (sprites: Sprites) => string;
}

export const PokeInfo: IPokeInfo = {
  getFrontSprite: (sprites: Sprites) => sprites.front_default
}