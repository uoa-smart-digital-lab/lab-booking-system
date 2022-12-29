<!------------------------------------------------------------------------------------------------------
The main App
------------------------------------------------------------------------------------------------------->
<script>
  // @ts-nocheck

    import { ApolloClient, InMemoryCache } from '@apollo/client';
    import { setClient } from 'svelte-apollo';
    import Items from './lib/Items.svelte';
    import Navbar from './lib/Navbar.svelte';
    import Login from './lib/Login.svelte';
    import QRcode from './lib/QRcode.svelte';
    import Booking from './lib/Booking.svelte';
    import { SvelteUIProvider, Divider, Modal } from '@svelteuidev/core';
    import { getQueryStringVal } from './lib/Querystring.svelte';

    let logindialog = false;
    let loading = true;
    let searchvalue = "";
    let inducted = false;
    let availability = true;
    let daybookingvalue = true;
    let upi = "";
    let sessionid = "";
    let name = "";
    let qrcode = "";
    let itemname = "";

    $: search = searchvalue;
    $: daybooking = daybookingvalue;

    const client = new ApolloClient({
      uri:  '/api',
      cache: new InMemoryCache()
    });
    setClient(client);

    function doneloading() {
      loading = false;
      return ("");
    }

    function dologin() {
      if (sessionid === "") {
        logindialog = true;
      }
      else {
        sessionid = "";
        name = "";
        upi = "";
        inducted = false;
        availability = true;
        logindialog = false;
      }
    }
    function closeLogin() {
      logindialog = false;
    }

    itemname = getQueryStringVal("item");
    function bookitem(theItem) {
      console.log(theItem);

      itemname = theItem.name;
    }

    function changesearch(newvalue) {
      searchvalue = newvalue;
    }

    function changeavailability(newvalue) {
      availability = newvalue;
    }

    function changeinducted(newvalue) {
      inducted = newvalue;
    }

    function changedaybooking(newvalue) {
      daybookingvalue = newvalue;
    }

    function loggedin(data) {
      upi = data.person.upi;
      name = data.person.name;
      sessionid = data.sessionid;
      logindialog = false;
    }

    qrcode = getQueryStringVal("qrcode");
</script>
<!----------------------------------------------------------------------------------------------------->



<!------------------------------------------------------------------------------------------------------
Styles
------------------------------------------------------------------------------------------------------->
<style>
  main {
    text-align: center;
    padding: 1em;
    max-width: 100%;
    margin: 0 auto;
    align-items:flex-start;
    display:block;
  }

</style>
<!----------------------------------------------------------------------------------------------------->


<!------------------------------------------------------------------------------------------------------
Layout
------------------------------------------------------------------------------------------------------->
  <main>
    <SvelteUIProvider themeObserver="light" fluid>
      {#if qrcode}
        <QRcode itemname={qrcode} />
      {:else}
        <Navbar context={itemname?"booking":"main"} {name} {itemname} {dologin} loggedin={sessionid != ""} 
            {changesearch} {changeavailability} {changeinducted} {changedaybooking} 
            {availability} {inducted} {daybooking}/>
        {#if itemname}
          <Booking {itemname} {daybooking} />
        {:else}
          {#if !loading}
            <Modal opened={logindialog} on:close={closeLogin} title="Log In" centered>
              <Login cancel={closeLogin} loggedin={loggedin} />
            </Modal>
          {/if}
          <Items {doneloading} {bookitem} {search} {inducted} {availability} {upi} loggedin={sessionid != ""}/>
        {/if}
      {/if}
    </SvelteUIProvider>
  </main>
<!----------------------------------------------------------------------------------------------------->