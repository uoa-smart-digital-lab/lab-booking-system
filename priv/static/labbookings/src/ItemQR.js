import { Component } from 'react';
import 'semantic-ui-css/semantic.min.css';
import { Card, Header} from 'semantic-ui-react'
import QRCode from "react-qr-code";


// ----------------------------------------------------------------------------------------------------
// Create a QR code for the item
// ----------------------------------------------------------------------------------------------------
class ItemQR extends Component
{
    constructor(props) {
        super (props);
        this.state = {
            link : window.location.protocol + "//" + window.location.hostname + ":" + window.location.port + "/?scan=" + this.props.name
        }
    }

    render ()
    {
        return (
            <>
                <Header centered as="h3" color='blue' block>
                    QR Code
                </Header>
                <Card.Group centered>
                    <Card color="blue" raised>
                        <Card.Content>
                            <Card.Header as="h3">
                                Scan in or out of {this.props.name}
                            </Card.Header>
                        </Card.Content>
                        <Card.Content>
                            <QRCode fgColor="#2185d0" value={this.state.link} title={this.state.link}/>
                        </Card.Content>
                        <Card.Content>
                            For this to work, your mobile device has to be using the University Wifi network.
                        </Card.Content>
                    </Card>
                </Card.Group>
            </>
        )
    }
}

export default ItemQR;
// ----------------------------------------------------------------------------------------------------
