<script context="module">
  // @ts-nocheck

// ----------------------------------------------------------------------------------------------------
// Get values in the query
// ----------------------------------------------------------------------------------------------------
export const getQuery = () => {
    if (typeof window !== 'undefined') {
      return new URLSearchParams(window.location.search);
    }
    return new URLSearchParams();
};
export const getQueryStringVal = (key) => {
    let query = getQuery();
    let returnValue = query.get(key);
    return returnValue;
};
export const removeQueryStringVal = (key) => {
    let query = getQuery();
    query.delete(key);
    let queryString = "";
    let firstQuery = true;
    for (let queryKey of query.keys()) {
        queryString += (firstQuery?"/?":"&") + queryKey + "=" + query.get(queryKey);
        firstQuery = false;
    }
    let link = window.location.protocol + "//" + window.location.hostname + ":" + window.location.port + queryString;
    window.location = link;
}
// ----------------------------------------------------------------------------------------------------

</script>