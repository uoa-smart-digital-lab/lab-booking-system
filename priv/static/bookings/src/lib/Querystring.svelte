<!------------------------------------------------------------------------------------------------------
  Useful functions for dealing with query parameters

  Author: Dr. Roy C. Davies
  Created: June 2023
  Contact: roy.c.davies@ieee.org
------------------------------------------------------------------------------------------------------->
<script context="module" lang="ts">

    // -------------------------------------------------------------------------------------------------
    // Functions
    // -------------------------------------------------------------------------------------------------
    // Get the query parameters
    export const getQuery = () : any => {
        if (typeof window !== 'undefined') {
          return new URLSearchParams(window.location.search);
        }
        return new URLSearchParams();
    };

    // Get a specific value from the query given the key
    export const getQueryStringVal = (key : string) : string => {
        let query : any = getQuery();
        return query.get(key);
    };

    // Remove a given key and value from the qeury and inject back into the URI
    export const removeQueryStringVal = (key : string) : any => {
        let query : any = getQuery();
        query.delete(key);
        let queryString : string = "";
        let firstQuery : boolean = true;
        for (let queryKey of query.keys()) {
            queryString += (firstQuery?"/?":"&") + queryKey + "=" + query.get(queryKey);
            firstQuery = false;
        }
        let link : any = window.location.protocol + "//" + window.location.hostname + ":" + window.location.port + queryString;
        window.location = link;
    }
</script>
<!----------------------------------------------------------------------------------------------------->