<!------------------------------------------------------------------------------------------------------
  An individual Item's qrcode or qr qrcode for a group of items
------------------------------------------------------------------------------------------------------->
<script lang="ts">
	import { Card, Text, Divider } from '@svelteuidev/core';
    import QrCode from "svelte-qrcode";
    import { query } from 'svelte-apollo';
    import { ITEMGET } from './Graphql.svelte';
    import type { Item } from './Graphql.svelte';
    import type { QueryVars } from './Types.svelte';

    // -------------------------------------------------------------------------------------------------
    // Parameters
    // -------------------------------------------------------------------------------------------------
    export let queryVars : QueryVars;                                   // QR Code for a group of items

    // -------------------------------------------------------------------------------------------------
    // Variables
    // -------------------------------------------------------------------------------------------------
    let qrlink = window.location.protocol + "//" + window.location.hostname + ":" + window.location.port + "/?" + (queryVars.qrsearch?"search=" + queryVars.qrsearch:"item=" + queryVars.itemName);

    // -------------------------------------------------------------------------------------------------
    // Functions
    // -------------------------------------------------------------------------------------------------
    let item : any;
    if (!queryVars.qrsearch) { item = query(ITEMGET, { variables: {name: queryVars.itemName} }); }

    const getname = (details : Item, name : string) : string => details.name ? details.name : name;
</script>
<!----------------------------------------------------------------------------------------------------->



<!------------------------------------------------------------------------------------------------------
Styles
------------------------------------------------------------------------------------------------------->
<style>

</style>
<!----------------------------------------------------------------------------------------------------->



<!------------------------------------------------------------------------------------------------------
Layout
------------------------------------------------------------------------------------------------------->
<Card p="lg">
    {#if queryVars.qrsearch}
        <a href = {qrlink}>
            <QrCode value={qrlink} alt={qrlink}/>
        </a>

        <Divider variant='dotted'/>

        <Text align='center' size='lg' weight={500}>
            Scan this for a list of {queryVars.qrsearch} items.
        </Text>
    {:else}
        {#if $item.loading}
            Loading...
        {:else if $item.error}
            Error: {$item.error.message}
        {:else}
            <a href = {qrlink}>
                <QrCode value={qrlink} alt={qrlink}/>
            </a>

            <Divider variant='dotted'/>

            <Text align='center' size='lg' weight={500}>
                Scan this for {getname($item.data.itemGet.details, $item.data.itemGet.name)}.
            </Text>

            <Divider variant='dotted'/>

            <Text align='center' size='sm'>
                {queryVars.itemName.toUpperCase()}
            </Text>
        {/if}
    {/if}
</Card>
<!----------------------------------------------------------------------------------------------------->
