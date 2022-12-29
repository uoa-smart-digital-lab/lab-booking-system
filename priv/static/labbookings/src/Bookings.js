import React, { Component } from 'react';
import 'semantic-ui-css/semantic.min.css';
import './App.css';
import { Card, Image, Button, Icon, Header, Menu, Checkbox } from 'semantic-ui-react'
import Calendar from 'react-awesome-calendar';
// import BookItem from './BookItem';

// const datesToAddContentTo = [tomorrow, in3Days, in5Days];

// ----------------------------------------------------------------------------------------------------
// Show the current bookings for an item and make a booking (if the user is allowed to)
// ----------------------------------------------------------------------------------------------------
class Bookings extends Component
{
    constructor(props) {
        super (props);
        this.state = 
        {
            makingBooking: false,
            loggedin: props.sessionid !== '',
            sessionid: this.props.sessionid,
            upi: this.props.upi,
            selectedstart:"",
            selectedend:"",
            selectedtitle: "",
            selectedcolor: "#cccccccc",
            choosingstartdate: true,
            daybookings: false
        }
        this.calendar = React.createRef();
    }

    componentDidMount() {
        let onClickDaySuper = this.calendar.current.onClickDay;
        
        this.calendar.current.onClickDay = (e) => { if (!this.state.daybookings) { return (onClickDaySuper(e))} else {this.onClickDay(e); }}
        this.setState({"makingBooking": false});
    }

    handleBooking = () => {
        window.location = this.state.link;
    }

    handleUrl = () => {
        // window.open(this.props.url, '_blank');
        window.location = this.props.url;
    }

    getname = (details, name) => {
        if (details.hasOwnProperty('name'))
        {
            return details.name
        }
        else {
            return name
        }
    }

    onChange = (date) => {

    }

    // Create a start and end time on the hours timeline
    onClickTimeLine = (date) => {
        let localdate = date.year.toString() + "-" + ((date.month<9)?"0":"") + (date.month+1).toString() + "-" + ((date.day<10)?"0":"") + date.day.toString() + "T" + ((Math.floor(date.hour)<10)?"0":"") + Math.floor(date.hour).toString() + ":00:00+00:00";
        let localdateplushalfhour = date.year.toString() + "-" + ((date.month<9)?"0":"") + (date.month+1).toString() + "-" + ((date.day<10)?"0":"") + date.day.toString() + "T" + ((Math.floor(date.hour)<10)?"0":"") + Math.floor(date.hour).toString() + ":30:00+00:00";
        if (this.state.choosingstartdate) {
            this.setState({"selectedstart": localdate}); 
            this.setState({"selectedtitle": "now choose end time"});
            this.setState({"selectedend": localdateplushalfhour});
            this.setState({"selectedcolor": "#cccccccc"});
            this.setState({"choosingstartdate": false});
        }
        else {
            this.setState({"selectedend": localdate}); 
            this.setState({"selectedtitle":"NEW BOOKING"});
            this.setState({"selectedcolor": "#2185d0cc"});
            this.setState({"choosingstartdate": true});
            this.props.dobooking({itemname: this.state.itemname, starttime: this.state.selectedstart, endtime: this.state.selectedend, upi: this.state.upi})
        }
    }

    // Create a start and end time on the days timeline
    onClickDay = (e) => {
        if (this.state.choosingstartdate) {
            let localdate = e.getFullYear().toString() + "-" + ((e.getMonth()<9)?"0":"") + (e.getMonth()+1).toString() + "-" + ((e.getDate()<10)?"0":"") + e.getDate().toString() + "T" + "00:00:00+00:00";
            let localdateplusoneday = e.getFullYear().toString() + "-" + ((e.getMonth()<9)?"0":"") + (e.getMonth()+1).toString() + "-" + ((e.getDate()<10)?"0":"") + e.getDate().toString() + "T" + "23:59:00+00:00";
            this.setState({"selectedstart": localdate}); 
            this.setState({"selectedtitle": "now choose end time"});
            this.setState({"selectedend": localdateplusoneday});
            this.setState({"selectedcolor": "#cccccccc"});
            this.setState({"choosingstartdate": false});
        }
        else {
            let localdate = e.getFullYear().toString() + "-" + ((e.getMonth()<9)?"0":"") + (e.getMonth()+1).toString() + "-" + ((e.getDate()<10)?"0":"") + e.getDate().toString() + "T" + "23:59:00+00:00";
            this.setState({"selectedend": localdate}); 
            this.setState({"selectedtitle":"NEW BOOKING"});
            this.setState({"selectedcolor": "#2185d0cc"});
            this.setState({"choosingstartdate": true});
            this.props.dobooking({itemname: this.state.itemname, starttime: this.state.selectedstart, endtime: this.state.selectedend, upi: this.state.upi})
        }
    }

    onClickEvent = (event) => {
    }

    cancelbooking = () => {
        this.setState({"selectedstart": ""}); 
        this.setState({"selectedtitle": ""});
        this.setState({"selectedend": ""});
        this.setState({"selectedcolor": "#cccccccc"});
        this.setState({"choosingstartdate": true});
        this.setState({"makingBooking": false})
    }

    editExistingBooking = (booking) => {
        
    }

    translateBookingsForCalendar = (bookings) => {
        let calendarEvents = [];
        let counter = 1;
        calendarEvents.push({
            id: 0,
            from: this.state.selectedstart,
            to: this.state.selectedend,
            title: this.state.selectedtitle,
            color: this.state.selectedcolor
        })
        bookings.forEach((item) => {
            calendarEvents.push({
                id: counter++,
                from: item.starttime,
                to: item.endtime,
                title: item.person.upi + " | " + item.person.name,
                color: '#2185d0'
            });
        })
        return calendarEvents;
    }

    BookingCard = () => {
        return (
            <>
                <Header centered as="h3" color='blue' block>
                    Book an item
                </Header>
                <Menu borderless color='blue' fluid widths={1}>
                    <Menu.Item>
                        <Button onClick={this.state.loggedin?this.props.dologout:this.props.dologin}>Log {this.state.loggedin?"out":"in"}</Button>
                    </Menu.Item>
                </Menu>
                <Card fluid centered color='blue'>
                    <Card.Content>
                        <Image src={this.props.image} size='medium'/>
                        <Card.Header as="h2">{this.getname(this.props.details, this.props.name)}</Card.Header>
                        <Card.Description>{this.props.name.toUpperCase()}</Card.Description>
                    </Card.Content>

                    {/* <Card.Content>
                        <Button icon fluid basic onClick={this.handleUrl}>
                            <Icon color='blue' name='external'/>
                            &nbsp; More Details
                        </Button>
                        &nbsp;
                        <Card.Description>
                            Use Calendar below to see and make bookings.
                        </Card.Description>
                    </Card.Content> */}
                    <Card.Content>
                        <Checkbox label='Multi-day booking' onChange={(e, data) => this.setState({"daybookings": data.checked})}/>
                    </Card.Content>
                    <Card.Content>
                        <Calendar
                            ref={this.calendar}
                            // header = {this.calendarHeader}
                            events={this.translateBookingsForCalendar(this.props.bookings)}
                            onChange={this.onChange}
                            onClickTimeLine={this.onClickTimeLine}                            
                            onClickEvent={this.onClickEvent}                            
                        />
                    </Card.Content>
                </Card>
            </>
        ) 
    }

    render ()
    {
        // if (this.state.makingBooking) {
        //     return (
        //         <BookItem starttime={this.state.selectedstart} endtime={this.state.selectedend} upi={this.state.upi} sessionid={this.state.sessionid} cancelbooking={this.cancelbooking} itemname={this.props.name}/>
        //     )
        // } else {
            return this.BookingCard();
        // }
    }
}

export default Bookings;
// ----------------------------------------------------------------------------------------------------