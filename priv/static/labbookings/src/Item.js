import React, { Component } from 'react';
import 'semantic-ui-css/semantic.min.css';
import { Card, Image, Button, Icon } from 'semantic-ui-react'


// ----------------------------------------------------------------------------------------------------
// Details about the item
// ----------------------------------------------------------------------------------------------------
class Item extends Component
{
    constructor(props) {
        super (props);
        this.state = {
            link : window.location.protocol + "//" + window.location.hostname + ":" + window.location.port + "/?item=" + this.props.name + (this.props.sessionid !== '' ? "&sessionid=" + this.props.sessionid : "")
        }
    }

    handleBooking = () => {
        window.location = this.state.link;
    }

    handleUrl = () => {
        // window.open(this.props.url, '_blank');
        window.location = this.props.url;
    }

    getname = (details, name) => {
        return (details.hasOwnProperty('name') ? details.name : name);
    }

    render ()
    {
        return (
            <Card color='blue'>
                <Card.Content>
                    <Image src={this.props.image} size='medium'/>
                    <Card.Header as="h2">{this.getname(this.props.details, this.props.name)}</Card.Header>
                    <Card.Description>{this.props.name.toUpperCase()}</Card.Description>
                    <Card.Meta>
                        {this.props.campus}
                    </Card.Meta>
                </Card.Content>

                <Card.Content>
                    <Button icon fluid basic onClick={this.handleUrl}>
                        <Icon color='blue' name='external'/>
                        &nbsp; More Details
                    </Button>
                    &nbsp;
                    <Button icon fluid basic onClick={this.handleBooking}>
                        <Icon color='blue' name='calendar'/>
                        &nbsp; Make Booking
                    </Button>
                </Card.Content>
            </Card>
        )
    }
}

export default Item;
// ----------------------------------------------------------------------------------------------------
