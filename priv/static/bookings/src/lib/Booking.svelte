<!------------------------------------------------------------------------------------------------------
  Use a calendar to manage bookings for a given item
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    // @ts-nocheck - known error with Calendar

	import { behavior, Modal } from 'svelte-fomantic-ui';
    import { query } from 'svelte-apollo';
    import { ITEMGET } from './Graphql.svelte';
    import Calendar from '@event-calendar/core';
    import DayGrid from '@event-calendar/day-grid';
    import List from '@event-calendar/list';
    import TimeGrid from '@event-calendar/time-grid';
    import Interaction from '@event-calendar/interaction';
    import ResourceTimeGrid from '@event-calendar/resource-time-grid';
    import ConfirmBooking from './ConfirmBooking.svelte';
    import type { Booking, Item } from './Graphql.svelte';
    import type { AppVars, QueryVars } from './Types.svelte';
    import Item from './Item.svelte';
	import { createEventDispatcher } from 'svelte';

    const dispatch = createEventDispatcher();

    // -------------------------------------------------------------------------------------------------
    // Parameters
    // -------------------------------------------------------------------------------------------------
    export let appVars : AppVars;
    export let queryVars : QueryVars;
    export let loggedIn : boolean;              // Whether a user is currently logged in

    // -------------------------------------------------------------------------------------------------
    // Variables
    // -------------------------------------------------------------------------------------------------
    let opened : boolean = false;               // Whether the dialog box is open or not
    let startTime : Date;                       // A starting date
    let endTime : Date;                         // An ending date
    let newStartTime : Date;                    // A new starting date
    let newEndTime : Date;                      // A new ending date
    let updating : boolean = false;             // Whether updating or create a new booking
    let editing : boolean = false;              // Whether editing a booking
    let plugins = [TimeGrid, DayGrid, List, ResourceTimeGrid, Interaction]; // Active Plugns for the calendar
    let ec : any;                               // Reference to the Calendar
    let details : any;                          // Additional booking details
    let bookingupi : string;                    // The booking upi
    let bookerStatus : string;                  // The booking person's status
    let itemsArray: string;

    // let items={
    //     hololens2_1:"Hololens2_1",
    //     hololens2_2:"Hololens2_2",
    //     hololens2_3:"Hololens2_3",
    //     hololens2_4:"Hololens2_4"
    // }


    // The GraphQL query structure for getting an item
    let item : any = query(ITEMGET, { variables: {name: appVars.item ? appVars.item.name : ( queryVars.name ? queryVars.name : "" ) } });

    // -------------------------------------------------------------------------------------------------
    // Functions
    // -------------------------------------------------------------------------------------------------
    function setItem (item : Item) { dispatch ( 'setItem', { item : item } ); return(""); }

    // This is a bit of a hack to create a date that is independent of the timezone as the server itself operates at zero UTC
    // Javascript date functions otherwise add the timezone which then puts the date in the wrong place in the server.
    const createDate = (date: Date) => {
        return (date.getFullYear().toString() + "-" + ((date.getMonth()<9)?"0":"") + (date.getMonth()+1).toString() + "-" + ((date.getDate()<10)?"0":"") + date.getDate().toString() + "T" + ((Math.floor(date.getHours())<10)?"0":"") + Math.floor(date.getHours()).toString() + ":00:00+00:00");
    }

    // Convert the bookings from the API into a format that the calendar can use
    const translateBookingsForCalendar = (bookings : [Booking]) : any => {
        let calendarEvents = [];
        let counter : number = 0;
        bookings.forEach((booking : Booking) => {
            let eventLength = (new Date(booking.endtime) - new Date(booking.starttime)) / (1000 * 3600);
            calendarEvents.push({
                id: counter++,
                start: booking.starttime,
                end: booking.endtime,
                title: booking.person.name + " (" + booking.person.upi + ") " + (booking.details.info ? (" - " + booking.details.info) : ""),
                backgroundColor: loggedIn && (booking.person.upi === appVars.session.person.upi) ? '#2185d0' : '#cccccc',
                editable: loggedIn && (booking.person.upi === appVars.session.person.upi),
                startEditable: loggedIn && (booking.person.upi === appVars.session.person.upi),
                durationEditable: loggedIn && (booking.person.upi === appVars.session.person.upi),
                allDay: (eventLength > 23),
                extendedProps: {upi: booking.person.upi, details: booking.details}
            });
        })
        return calendarEvents;
    }

    // Close the dialog box (eg after cancel button pressed)
    const closeDialog = () => { item.refetch(); ec.setOption("events", translateBookingsForCalendar($item.data.itemGet.bookings)); ec.unselect(); behavior("ConfirmBookingDialog", "hide"); opened = false; }

    // Called when the update or new booking is successful (and sends the updated item)
    const success = (updatedItem : Item) => { closeDialog(); }

    const newEvent = (info : any) => {
        if(loggedIn) {
            ec.unselect(); 
            updating=false;
            editing=false;
            newStartTime = startTime = createDate(info.start);
            newEndTime = endTime = createDate(info.end);
            details = {info:""};
            bookingupi = appVars.session.person.upi;
            bookerStatus = appVars.session.person.status.toString();
            behavior("ConfirmBookingDialog", "show");
            opened = true;
        }
    }

    const updateEvent = (info : any) => {
        if (loggedIn) {
            updating=true;
            editing=false;
            newStartTime = createDate(info.event.start);
            startTime = createDate(info.oldEvent.start);
            newEndTime = createDate(info.event.end);
            endTime = createDate(info.oldEvent.end);
            details = info.event.extendedProps.details;
            bookingupi = info.event.extendedProps.upi;
            bookerStatus = appVars.session.person.status.toString();
            behavior("ConfirmBookingDialog", "show");
            opened = true;
        }
    }

    const editEvent = (info : any) => {
        if (loggedIn) {
            updating=false;
            editing=true;
            newStartTime = startTime = createDate(info.event.start);
            newEndTime = endTime = createDate(info.event.end);
            details = info.event.extendedProps.details;
            bookingupi = info.event.extendedProps.upi;
            bookerStatus = appVars.session.person.status.toString();
            behavior("ConfirmBookingDialog", "show");
            opened = true;
        }
    }

    const changeView = (info : any) => {
        ec.setOption("date", info.date);
        ec.setOption("view", "timeGridDay");
    }
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
{#if $item.loading}
    Loading...
{:else if $item.error}
    There is no item called \'{queryVars.name}\' in the system.
{:else}
    <Modal id="ConfirmBookingDialog" ui tiny>
        {#if opened}
            <ConfirmBooking title={(updating ? "Update" : (editing ? "Change" : "Create new")) + " Booking"} {details} sessionid={appVars?appVars.session?appVars.session.sessionid:"":""} {closeDialog} {success} {updating} {editing} {bookingupi} {bookerStatus} upi={appVars?appVars.session?appVars.session.person.upi:"":""} itemName={appVars?appVars.item?appVars.item.name:"":""} {startTime} {endTime} {newStartTime} {newEndTime} />
        {/if}
    </Modal>

    {setItem ($item.data.itemGet)}
    <div style={"padding-top:55px; margin: 5px;"}>
        <!-- <Select ui fluid search dropdown multiple bind:selected={itemsArray}>
            <Option value="">Select Items</Option>
            {#each Object.keys(items) as key}
                <Option value={key}>{items[key]}</Option>
            {/each}
        </Select> -->
        <Calendar bind:this={ec} {plugins} options = {{
            scrollTime: '09:00:00',
            views: {
                timeGridDay: {pointer: true},
                dayGridMonth: {pointer: true}
            },
            headerToolbar: {start: 'title', center: '', end: 'dayGridMonth,timeGridWeek,timeGridDay prev,today,next'},
            events: translateBookingsForCalendar($item.data.itemGet.bookings),
            eventResize: updateEvent,
            eventDrop: updateEvent,
            eventClick: editEvent,
            select: newEvent,
            dateClick: changeView,
            nowIndicator: true,
            editable: false,
            selectable: loggedIn,
            view: "dayGridMonth",
            slotDuration: '01:00:00'
        }} />
    </div>
{/if}
<!----------------------------------------------------------------------------------------------------->
