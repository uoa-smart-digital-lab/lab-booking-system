<!------------------------------------------------------------------------------------------------------
  An individual Item's qrcode or qr qrcode for a group of items
------------------------------------------------------------------------------------------------------->
<script lang="ts">
	import { Card, Content, Link } from 'svelte-fomantic-ui';
    import QrCode from "svelte-qrcode";
    import { query } from 'svelte-apollo';
    import { ITEMGET } from './Graphql.svelte';
    import type { Item } from './Graphql.svelte';
    import type { QueryVars } from './Types.svelte';

    // -------------------------------------------------------------------------------------------------
    // Parameters
    // -------------------------------------------------------------------------------------------------
    export let queryVars : QueryVars;                               // Details about the item itself

    // -------------------------------------------------------------------------------------------------
    // Variables
    // -------------------------------------------------------------------------------------------------
    let qrlink = window.location.protocol + "//" + window.location.hostname + ":" + window.location.port + "/?" + (queryVars.qrsearch?"search=" + queryVars.qrsearch:"item=" + queryVars.qrcode);

    // -------------------------------------------------------------------------------------------------
    // Functions
    // -------------------------------------------------------------------------------------------------
    let item : any;
    if (queryVars.qrcode) { item = query(ITEMGET, { variables: {name: queryVars.qrcode} }); }

    const getname = (details : Item, name : string) : string => details.name ? details.name : name.toUpperCase();
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
<Card ui centered>
    {#if queryVars.qrsearch}
        <Link image href = {qrlink}>
            <QrCode value={qrlink} alt={qrlink}/>
        </Link>
        <Content>
            <center>
                Scan this for a list of {queryVars.qrsearch} items.
            </center>
        </Content>
    {:else}
        {#if $item.loading}
            Loading...
        {:else if $item.error}
            Error: {$item.error.message}
        {:else}
            <Link image href={qrlink}>
                <QrCode value={qrlink} alt={qrlink}/>
            </Link>
            <Content>
                <center>
                    Scan this for {getname($item.data.itemGet.details, $item.data.itemGet.name)}.
                </center>
            </Content>
            <Content extra>
                <center>
                    {$item.data.itemGet.name.toUpperCase()}
                </center>
            </Content>
        {/if}
    {/if}
</Card>
<!----------------------------------------------------------------------------------------------------->
