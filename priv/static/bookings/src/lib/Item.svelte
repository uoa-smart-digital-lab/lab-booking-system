<!------------------------------------------------------------------------------------------------------
  A single item card

  Author: Dr. Roy C. Davies
  Created: June 2023
  Contact: roy.c.davies@ieee.org
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    import { Card, Content, Image, Header, Buttons, Button, Description, Meta} from "svelte-fomantic-ui";
    import type { Item as ItemT, ItemDetails, Person} from './Graphql.svelte';
	import { createEventDispatcher } from 'svelte';
    import QRcode from "./QRcode.svelte";
    import type { QueryVars } from './Types.svelte';

    const dispatch = createEventDispatcher();

    // -------------------------------------------------------------------------------------------------
    // Parameters
    // -------------------------------------------------------------------------------------------------
    export let item : ItemT                         // Details about the item
    export let loggedIn : boolean;                  // Whether the user is logged in or not
    export let available : boolean;                 // Whether the item is available to be booked
    export let upi : string;                        // Logged in user's UPI
    export let qrcode : boolean;                    // Show the QR code for the item instead of the picture
    export let list : boolean;                      // True if list mode, otherwise display as card
    export let ui = false;
    export let numCols: number;

    // -------------------------------------------------------------------------------------------------
    // Variables
    // -------------------------------------------------------------------------------------------------

    // -------------------------------------------------------------------------------------------------
    // Functions
    // -------------------------------------------------------------------------------------------------
    // Check the list of inductions to see if user is allowed to book this item
    $: allowed = (item.inductions.reduce((acc : boolean, curr : Person) => acc || (curr.upi === upi), false));

    function getName (details : ItemDetails, name : string) : string {
        return (details.name ? details.name : name);
    }

    // Work out an appropriate message.  The loggedin parameter is to ensure this is updated when the user logs in.
    function getAccessMessage(_loggedIn, available) : string {
        let returnString : string;
        if (available) {
            switch (item.access.toString()) {
                case "FREE" : returnString = "You can book this item without induction."; break;
                case "INDUCTION" : 
                    if (allowed) {
                        returnString = "You can book this item."
                    }else{
                        returnString = "You must be inducted to book this item";
                    }
                    break;
                default : returnString = "This item can only be used under supervision."; break;
            }
        }
        else {
            returnString = "This item is currently booked.";
        }
        return (returnString);
    }

    function bookItem () { dispatch ( 'book', { item : item } ) }

    function showDetails () { dispatch ( 'showDetails', { item : item } ) }
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
{#if qrcode}
    <QRcode queryVars={{qrcode: item.name, name: item.name, qrsearch: "", search: ""}}/>
{:else}
    <Card {ui}>
        {#if list}
            <Image style={"display:flex; align-items: center; padding-left: 1em; padding-right: 1em; background-color:white;"}>
                <Image ui tiny src={item.image}/>
            </Image>

            <Content style={"display:flex; justify-content: center; flex-direction:column;"}>
                <Header>{getName(item.details, item.name)}</Header>
                <Description>{item.name.toUpperCase()}</Description>
                <Meta>{getAccessMessage(loggedIn, available)}</Meta>
            </Content>

                {#if numCols === 1}
                    <Content extra style={"padding: 0 0;"}>
                        <Buttons ui two buttons fluid bottom attached>
                            <Button ui primary on:click={bookItem}>book</Button>
                            <Button ui green on:click={showDetails}>info</Button>
                        </Buttons>
                    </Content>
                {:else}
                    <Content style={"display:flex; align-items: center;"}>
                        <Buttons ui _={(numCols <= 2)?"vertical":""} style={"margin-left:auto; margin-right:0"}>
                            <Button ui primary on:click={bookItem} style={"width:150px;"}>book</Button>
                            <Button ui green on:click={showDetails} style={"width:150px;"}>info</Button>
                        </Buttons>
                    </Content>
                {/if}
        {:else}
            <Image style={"padding-left: 1em; padding-right: 1em; background-color:white;"}>
                <Image ui src={item.image}/>
            </Image>

            <Content>
                <Header center aligned>{getName(item.details, item.name)}</Header>
                <Description center aligned>{item.name.toUpperCase()}</Description>
                <Meta center aligned>{getAccessMessage(loggedIn, available)}</Meta>
            </Content>

            <Buttons ui wrapping two buttons bottom attached>
                <Button ui primary on:click={bookItem}>book</Button>
                <Button ui green on:click={showDetails}>info</Button>
            </Buttons>
        {/if}
    </Card>
{/if}
<!----------------------------------------------------------------------------------------------------->
