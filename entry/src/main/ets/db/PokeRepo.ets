import http from '@ohos.net.http';
import relationalStore from '@ohos.data.relationalStore';
import { AsyncCallback, BusinessError } from '../common/AsyncCallback';
import { generateBucket, Pokemon } from '../model/Pokemon';
import { POKE_TABLE } from './PokeTable';
import { store } from './RDB';
import ArrayList from '@ohos.util.ArrayList';

export class PokeRepo {
  LOG_TAG: string = "PokeRepo-"

  getPokeInfo(poke: Pokemon, onResult: AsyncCallback<string, BusinessError<Error>>) {
    // Each HttpRequest corresponds to an HttpRequestTask object and cannot be reused.
    const httpRequest = http.createHttp();
    console.info(this.LOG_TAG + 'call http-' + poke.name);
    // Subscribe to the HTTP response header, which is returned earlier than HttpRequest. You can subscribe to HTTP Response Header events based on service requirements.
    // on('headerReceive', AsyncCallback) will be replaced by on('headersReceive', Callback) in API version 8. 8+
    httpRequest.on('headersReceive', (header) => {
      console.info('header: ' + JSON.stringify(header));
    });

    const callback = async (err: Error, data: http.HttpResponse) => {
      if (!err) {
        console.info(this.LOG_TAG + 'call http end-' + poke.name);
        // data.result contains the HTTP response. Parse the response based on service requirements.
        console.info(this.LOG_TAG + 'Result:' + data.result);
        console.info('code:' + data.responseCode);
        // data.header contains the HTTP response header. Parse the content based on service requirements.
        console.info('header:' + JSON.stringify(data.header));
        console.info('cookies:' + data.cookies); // 8+
        const json: string = data.result as string
        onResult.onCallback(null, json)
      } else {
        onResult.onCallback(new BusinessError(0, err.message), null)
        console.info('error:' + JSON.stringify(err));
        // Call the destroy() method to release resources after the call is complete.
        httpRequest.destroy();
      }
    }
    httpRequest.request(
      // Set the URL of the HTTP request. You need to define the URL. Set the parameters of the request in extraData.
      poke.url,
      {
        method: http.RequestMethod.GET, // Optional. The default value is http.RequestMethod.GET.
        // You can add the header field based on service requirements.
        header: {
          'Content-Type': 'application/json'
        },
        // This field is used to transfer data when the POST request is used.
        connectTimeout: 60000, // Optional. The default value is 60000, in ms.
        readTimeout: 60000, // Optional. The default value is 60000, in ms.
      }, callback
    )
  }

  callPokemonsFromServer(onResult: AsyncCallback<string, BusinessError<Error>>) {
    // Each HttpRequest corresponds to an HttpRequestTask object and cannot be reused.
    const httpRequest = http.createHttp();

    // Subscribe to the HTTP response header, which is returned earlier than HttpRequest. You can subscribe to HTTP Response Header events based on service requirements.
    // on('headerReceive', AsyncCallback) will be replaced by on('headersReceive', Callback) in API version 8. 8+
    httpRequest.on('headersReceive', (header) => {
      console.info('header: ' + JSON.stringify(header));
    });

    const callback = async (err: Error, data: http.HttpResponse) => {
      if (!err) {
        // data.result contains the HTTP response. Parse the response based on service requirements.
        console.info('Result:' + data.result);
        console.info('code:' + data.responseCode);
        // data.header contains the HTTP response header. Parse the content based on service requirements.
        console.info('header:' + JSON.stringify(data.header));
        console.info('cookies:' + data.cookies); // 8+
        const json: string = data.result as string
        onResult.onCallback(null, json)
      } else {
        onResult.onCallback(new BusinessError(0, err.message), null)
        console.info('error:' + JSON.stringify(err));
        // Call the destroy() method to release resources after the call is complete.
        httpRequest.destroy();
      }
    }
    httpRequest.request(
      // Set the URL of the HTTP request. You need to define the URL. Set the parameters of the request in extraData.
      "https://pokeapi.co/api/v2/pokemon?limit=2000&offset=0",
      {
        method: http.RequestMethod.GET, // Optional. The default value is http.RequestMethod.GET.
        // You can add the header field based on service requirements.
        header: {
          'Content-Type': 'application/json'
        },
        // This field is used to transfer data when the POST request is used.
        connectTimeout: 60000, // Optional. The default value is 60000, in ms.
        readTimeout: 60000, // Optional. The default value is 60000, in ms.
      }, callback
    )
  }

  async getByName(name: string): Promise<Pokemon> {
    let predicates = new relationalStore.RdbPredicates(POKE_TABLE.tableName);
    predicates.equalTo('name', name);
    const promisequery = store.query(predicates, POKE_TABLE.columns);
    return await promisequery.then((resultSet) => {
      resultSet.goToFirstRow()
      const id = resultSet.getLong(resultSet.getColumnIndex("id"));
      const name = resultSet.getString(resultSet.getColumnIndex("name"));
      const url = resultSet.getString(resultSet.getColumnIndex("url"));
      const time = resultSet.getLong(resultSet.getColumnIndex("time"));
      let picUrl = ""
      try {
        picUrl = resultSet.getString(resultSet.getColumnIndex("picUrl"));
      } catch (e) {
      }
      resultSet.close();
      return new Pokemon(
        id,
        name,
        url,
        picUrl,
        time
      );
    })
  }

  async count(): Promise<number> {
    const q = 'SELECT COUNT(*) FROM ' + POKE_TABLE.tableName
    const resultSet = await store.querySql(q, [])
    resultSet.goToFirstRow();
    const count = resultSet.getLong(0);
    console.info(this.LOG_TAG + "poke count-" + count)
    return count
  }

  async getAll(): Promise<ArrayList<Pokemon>> {
    const predicates = new relationalStore.RdbPredicates(POKE_TABLE.tableName);
    const resultSet = await store.query(predicates, POKE_TABLE.columns);
    const pokemons = new ArrayList<Pokemon>()
    while (!resultSet.isAtLastRow) {
      resultSet.goToNextRow()
      const id = resultSet.getLong(resultSet.getColumnIndex("id"));
      const name = resultSet.getString(resultSet.getColumnIndex("name"));
      const url = resultSet.getString(resultSet.getColumnIndex("url"));
      const time = resultSet.getLong(resultSet.getColumnIndex("time"));
      let picUrl = ""
      try {
        picUrl = resultSet.getString(resultSet.getColumnIndex("picUrl"));
      } catch (e) {
      }
      pokemons.add(new Pokemon(
        id,
        name,
        url,
        picUrl,
        time
      )
      )
    }
    pokemons.length
    resultSet.close();
    return pokemons;
  }

  async updateData(poke: Pokemon) {
    let predicates = new relationalStore.RdbPredicates(POKE_TABLE.tableName);
    predicates.equalTo('id', poke.id);
    poke.time = new Date().getTime()
    const bucket = generateBucket(poke)
    try {
      await store.update(bucket, predicates);
    } catch (e) {
      if (e instanceof Error) {
        console.error('Failed to update Pokemon:', e.message);
      } else {
        console.error('Unknown error occurred during update');
      }
    }
  }

  async insertAll(pokemons: Pokemon[]) {
    const backets: Array<relationalStore.ValuesBucket> = pokemons.map(poke => {
      poke.time = new Date().getTime()
      return generateBucket(poke)
    })
    // Use a transaction to insert data.
    store.beginTransaction();
    await store.batchInsert(POKE_TABLE.tableName, backets)
    store.commit();
  }
}
