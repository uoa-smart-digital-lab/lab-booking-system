<!------------------------------------------------------------------------------------------------------
  Login dialog box

  Author: Dr. Roy C. Davies
  Created: June 2023
  Contact: roy.c.davies@ieee.org
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    import {Text} from "svelte-fomantic-ui";

    export let content = {};

    console.log(content);

</script>

<Text ui>{content["__typename"]}</Text>
