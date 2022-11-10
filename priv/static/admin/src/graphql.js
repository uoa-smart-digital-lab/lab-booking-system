import {
    ApolloClient,
    InMemoryCache
  } from "@apollo/client";


// ----------------------------------------------------------------------------------------------------
// Common data for GraphQL
// ----------------------------------------------------------------------------------------------------
var GraphQL = 
{
  client : new ApolloClient({
    uri: '/api',
    cache: new InMemoryCache()
  }),

  fetch : ({uri, headers, body}) => {
    return new Promise ((resolve, reject) => {
      fetch(uri, { method:"POST", headers:headers, body:body })
      .then (result => result.json())
      .then ((result) => {
          resolve(result)
      })
      .catch ((err) => {
          reject(err);
      });
    });
  }
}
// ----------------------------------------------------------------------------------------------------
export default GraphQL;
// ----------------------------------------------------------------------------------------------------
