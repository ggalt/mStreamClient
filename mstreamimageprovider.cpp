/****************************************************************************
**
** Copyright (C) 2015 Canonical Limited and/or its subsidiary(-ies)
** Contact: https://www.qt.io/licensing/
**
** This file is part of the demonstration applications of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** BSD License Usage
** Alternatively, you may use this file under the terms of the BSD license
** as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of The Qt Company Ltd nor the names of its
**     contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

/****************************************************************************
**
** Modifications made by George Galt under BSD license 2019
**
****************************************************************************/




#include "mstreamimageprovider.h"

AsyncImageResponse::AsyncImageResponse(const QString &id, const QSize &requestedSize, QUrl imageURL, QByteArray accessToken )
    : m_id(id), m_requestedSize(requestedSize), m_imageURL(imageURL), m_accessToken( accessToken)
{
    setAutoDelete(false);
}

QQuickTextureFactory* AsyncImageResponse::textureFactory() const
{
    return QQuickTextureFactory::textureFactoryForImage(m_image);
}

void AsyncImageResponse::run()
{
    QNetworkAccessManager *manager = new QNetworkAccessManager(this);
    QNetworkRequest request;
    QUrl fullURL = QUrl( m_imageURL.toString() + m_id);
    request.setUrl(fullURL);
    request.setRawHeader("Content-Type", "application/json;charset=UTF-8");
    request.setRawHeader("datatype", "json");
    request.setRawHeader("x-access-token", m_accessToken);
    QNetworkReply *reply = manager->get(request);

    while(!reply->isFinished() && reply->error() == QNetworkReply::NoError ) {
        QThread::usleep(100);
    }

    if( reply->error() > QNetworkReply::NoError ) {
        qDebug() << "Image Error: " << reply->errorString();
        m_image = QImage(50, 50, QImage::Format_RGB32);
        m_image.fill(Qt::gray);
        emit finished();
    } else {

        m_reader.setDevice(reply);
        m_image = m_reader.read();
        reply->deleteLater();

        if (m_requestedSize.isValid())
            m_image = m_image.scaled(m_requestedSize, Qt::KeepAspectRatio);

        emit finished();
    }
}

QQuickImageResponse *AsyncImageProvider::requestImageResponse(const QString &id, const QSize &requestedSize)
{
    AsyncImageResponse *response = new AsyncImageResponse(id, requestedSize, QUrl(m_imageServerURL), m_accessToken );
    pool.start(response);
    return response;
}


//class ImageProviderExtensionPlugin : public QQmlExtensionPlugin
//{
//    Q_OBJECT
//    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)
//public:
//    void registerTypes(const char *uri) override
//    {
//        Q_UNUSED(uri);
//    }

//    void initializeEngine(QQmlEngine *engine, const char *uri) override
//    {
//        Q_UNUSED(uri);
//        engine->addImageProvider("async", new AsyncImageProvider);
//    }

//};

//#include "imageresponseprovider.moc"
