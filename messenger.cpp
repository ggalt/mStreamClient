#include "messenger.h"

Messenger::Messenger(QObject *parent) : QObject(parent)
{
    m_imageProvider = new AsyncImageProvider();
}


void Messenger::setImageServerURL( const QString &imageURL)
{
    m_imageServerURL = imageURL;
    m_imageProvider->setImageServerURL(imageURL);
    qDebug() << "messenger got image URL:" << imageURL;
    emit imageServerURLChanged();
}

void Messenger::setAccessToken( const QByteArray &token )
{
    m_accessToken = token;
    m_imageProvider->setAccessToken(token);
    qDebug() << "messenger got token:" << token;
    emit accessTokenChanged();
}
