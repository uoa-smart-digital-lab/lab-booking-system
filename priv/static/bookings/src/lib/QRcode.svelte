<!------------------------------------------------------------------------------------------------------
  An individual Item's qrcode or qr qrcode for a group of items
------------------------------------------------------------------------------------------------------->
<script lang="ts">
	import { Card, Text, Divider } from '@svelteuidev/core';
    import QrCode from "svelte-qrcode";
    import { query } from 'svelte-apollo';
    import { ITEMGET } from './Graphql.svelte';
    import type { Item } from './Graphql.svelte';

    // -------------------------------------------------------------------------------------------------
    // Parameters
    // -------------------------------------------------------------------------------------------------
    export let itemName : string = "";               // Details about the item itself
    export let qrsearch : string = "";               // QR Code for a group of items

    // -------------------------------------------------------------------------------------------------
    // Variables
    // -------------------------------------------------------------------------------------------------
    let qrlink = window.location.protocol + "//" + window.location.hostname + ":" + window.location.port + "/?" + (qrsearch?"search=" + qrsearch:"item=" + itemName);

    // -------------------------------------------------------------------------------------------------
    // Functions
    // -------------------------------------------------------------------------------------------------
    let item : any;
    if (!qrsearch) { item = query(ITEMGET, { variables: {name: itemName} }); }

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
    {#if qrsearch}
        <a href = {qrlink}>
            <QrCode value={qrlink} alt={qrlink}/>
        </a>

        <Divider variant='dotted'/>

        <Text align='center' size='lg' weight={500}>
            Scan this for a list of {qrsearch} items.
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
                {itemName.toUpperCase()}
            </Text>
        {/if}
    {/if}
</Card>
<!----------------------------------------------------------------------------------------------------->
